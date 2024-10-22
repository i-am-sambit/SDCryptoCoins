//
//  HomeViewController.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 21/10/24.
//

import Combine
import UIKit

final class HomeViewController: UIViewController {
    private var headerView: UIView!
    private var footerView: UIView!
    private var searchView: UIView!
    private var tableView: UITableView!
    
    private var searchViewHeightConstraint: NSLayoutConstraint!
    
    private weak var coordinator: HomeCoordinator?
    private var viewModel: HomeViewModel?
    
    private var cancellables = Set<AnyCancellable>()
    private var dispatchWorkItem: DispatchWorkItem?
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        self.view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        return activityIndicator
    }()
    
    func inject(viewModel: HomeViewModel, coordinator: HomeCoordinator? = nil) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createView()
        
        guard let viewModel else { return }
        viewModel.$cryptoCoins
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.footerView.isHidden = isLoading
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)
        
        viewModel.fetchCryptoCoins()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        headerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: self.view.safeAreaInsets.top + 50).isActive = true
        
        footerView.heightAnchor.constraint(equalToConstant: 122 + self.view.safeAreaInsets.bottom).isActive = true
        footerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        tableView.topAnchor.constraint(equalTo: searchView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.footerView.topAnchor).isActive = true
    }
}

extension HomeViewController {
    private func createView() {
        self.view.backgroundColor = .background
        createHeaderView()
        createBodyView()
        createFilterView()
    }
    
    private func createHeaderView() {
        headerView = UIView()
        headerView.backgroundColor = .primaryTheme
        self.view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let headerTitleLabel = UILabel()
        headerTitleLabel.text = "COIN"
        headerTitleLabel.font = .boldSystemFont(ofSize: 20)
        headerTitleLabel.textColor = .white
        headerView.addSubview(headerTitleLabel)
        headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.bottomAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 10).isActive = true
        headerTitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        
        let searchButton = UIButton()
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = .white
        headerView.addSubview(searchButton)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.addAction(
            UIAction { [unowned self, unowned searchButton] _ in
                searchButton.isSelected = !searchButton.isSelected
                self.searchViewHeightConstraint.constant = searchButton.isSelected ? 65 : 0
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear) {
                    self.view.layoutIfNeeded()
                }
            },
            for: .touchUpInside
        )
        
        searchButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        headerView.bottomAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 5).isActive = true
        headerView.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor, constant: 16).isActive = true
    }
    
    private func createFilterView() {
        footerView = UIView()
        footerView.backgroundColor = .filterBackground
        self.view.addSubview(footerView)
        footerView.insetsLayoutMarginsFromSafeArea = true
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 10
        verticalStackView.distribution = .fillEqually
        footerView.addSubview(verticalStackView)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        verticalStackView.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 16).isActive = true
        verticalStackView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16).isActive = true
        footerView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: 16).isActive = true
        footerView.trailingAnchor.constraint(equalTo: verticalStackView.trailingAnchor, constant: 16).isActive = true
        
        let horizontaltopStackView = UIStackView()
        horizontaltopStackView.axis = .horizontal
        horizontaltopStackView.spacing = 10
        horizontaltopStackView.distribution = .fillEqually
        verticalStackView.addArrangedSubview(horizontaltopStackView)
        horizontaltopStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let activeCoinsButton = UIButton()
        activeCoinsButton.setTitle("Active coins", for: .normal)
        activeCoinsButton.setTitleColor(.black, for: .normal)
        activeCoinsButton.titleLabel?.font = .systemFont(ofSize: 14)
        activeCoinsButton.backgroundColor = .filterTopButton
        activeCoinsButton.layer.cornerRadius = 20
        horizontaltopStackView.addArrangedSubview(activeCoinsButton)
        activeCoinsButton.translatesAutoresizingMaskIntoConstraints = false
        activeCoinsButton.addAction(
            UIAction { [weak self, weak activeCoinsButton] _ in
                self?.viewModel?.filterOnlyActiveCoins()
                activeCoinsButton?.isSelected.toggle()
            },
            for: .touchUpInside
        )
        
        let inactiveCoinsButton = UIButton()
        inactiveCoinsButton.setTitle("Inactive coins", for: .normal)
        inactiveCoinsButton.setTitleColor(.black, for: .normal)
        inactiveCoinsButton.titleLabel?.font = .systemFont(ofSize: 14)
        inactiveCoinsButton.backgroundColor = .filterTopButton
        inactiveCoinsButton.layer.cornerRadius = 20
        horizontaltopStackView.addArrangedSubview(inactiveCoinsButton)
        inactiveCoinsButton.translatesAutoresizingMaskIntoConstraints = false
        inactiveCoinsButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel?.filterOnlyInactiveCoins()
            },
            for: .touchUpInside
        )
        
        let onlyTokenButton = UIButton()
        onlyTokenButton.setTitle("Only Tokens", for: .normal)
        onlyTokenButton.setTitleColor(.black, for: .normal)
        onlyTokenButton.titleLabel?.font = .systemFont(ofSize: 14)
        onlyTokenButton.backgroundColor = .filterTopButton
        onlyTokenButton.layer.cornerRadius = 20
        horizontaltopStackView.addArrangedSubview(onlyTokenButton)
        onlyTokenButton.translatesAutoresizingMaskIntoConstraints = false
        onlyTokenButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel?.filterOnlyToken()
            },
            for: .touchUpInside
        )
        
        let horizontalBottomStackView = UIStackView()
        horizontalBottomStackView.axis = .horizontal
        horizontalBottomStackView.spacing = 10
        horizontalBottomStackView.distribution = .fillProportionally
        verticalStackView.addArrangedSubview(horizontalBottomStackView)
        horizontalBottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let onlyCoinsButton = UIButton()
        onlyCoinsButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        onlyCoinsButton.setTitle("Only coins", for: .normal)
        onlyCoinsButton.setTitleColor(.black, for: .normal)
        onlyCoinsButton.titleLabel?.font = .systemFont(ofSize: 14)
        onlyCoinsButton.backgroundColor = .filterBottomButton
        onlyCoinsButton.layer.cornerRadius = 20
        horizontalBottomStackView.addArrangedSubview(onlyCoinsButton)
        onlyCoinsButton.translatesAutoresizingMaskIntoConstraints = false
        onlyCoinsButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel?.filterOnlyActiveCoins()
            },
            for: .touchUpInside
        )
        
        let newCryptoButton = UIButton()
        newCryptoButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        newCryptoButton.setTitle("New cryptos", for: .normal)
        newCryptoButton.setTitleColor(.black, for: .normal)
        newCryptoButton.titleLabel?.font = .systemFont(ofSize: 14)
        newCryptoButton.backgroundColor = .filterBottomButton
        newCryptoButton.layer.cornerRadius = 20
        horizontalBottomStackView.addArrangedSubview(newCryptoButton)
        newCryptoButton.translatesAutoresizingMaskIntoConstraints = false
        newCryptoButton.addAction(
            UIAction { [weak self] _ in
                self?.viewModel?.filterOnlyNewCoins()
            },
            for: .touchUpInside
        )
        
        let spacerView = UIView()
        horizontalBottomStackView.addArrangedSubview(spacerView)
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func createBodyView() {
        searchView = UIView()
        searchView.backgroundColor = .primaryTheme
        self.view.addSubview(searchView)
        searchView.translatesAutoresizingMaskIntoConstraints = false
        searchView.clipsToBounds = true
        
        searchViewHeightConstraint = searchView.heightAnchor.constraint(equalToConstant: 0)
        searchViewHeightConstraint.isActive = true
        searchView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        searchView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        searchView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search coin or symbol"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .primaryTheme
        searchBar.layer.cornerRadius = 5
        searchBar.isTranslucent = true
        searchBar.searchTextField.backgroundColor = .background
        searchView.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.topAnchor.constraint(equalTo: searchView.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: searchView.leadingAnchor).isActive = true
        searchView.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        searchView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor).isActive = true
        
        tableView = UITableView()
        tableView.dataSource = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.tableFooterView = UIView()
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.cryptoCoins.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HomeTableViewCell.reuseIdentifier, for: indexPath) as! HomeTableViewCell
        cell.cryptoCoin = viewModel?.cryptoCoins[indexPath.row]
        return cell
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dispatchWorkItem?.cancel()
        let workItem = DispatchWorkItem { [unowned self] in
            self.viewModel?.filterCoins(with: searchText.lowercased())
        }
        dispatchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: workItem)
    }
}

#Preview {
    HomeViewController()
}
