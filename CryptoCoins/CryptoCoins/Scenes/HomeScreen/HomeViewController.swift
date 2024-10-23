//
//  HomeViewController.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 21/10/24.
//

import Combine
import UIKit

final class HomeViewController: UIViewController {
    private weak var coordinator: HomeCoordinator?
    private var viewModel: HomeViewModel?
    
    private var cancellables = Set<AnyCancellable>()
    private var dispatchWorkItem: DispatchWorkItem?
    
    private lazy var headerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "COIN"
        label.font = .boldSystemFont(ofSize: 20)
        label.textColor = .white
        headerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .white
        button.contentHorizontalAlignment = .trailing
        headerView.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(
            UIAction { [unowned self, unowned button] _ in
                button.isSelected = !button.isSelected
                
                self.searchBar.text = ""
                self.viewModel?.filterText = ""
                self.searchViewHeightConstraint.constant = button.isSelected ? 65 : 0
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear) {
                    self.view.layoutIfNeeded()
                }
            },
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var headerView: UIView = {
        let headerView = UIView()
        headerView.backgroundColor = .primaryTheme
        self.view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }()
    
    private lazy var footerView: UIView = {
        let footerView = UIView()
        footerView.backgroundColor = .filterBackground
        self.view.addSubview(footerView)
        footerView.insetsLayoutMarginsFromSafeArea = true
        footerView.translatesAutoresizingMaskIntoConstraints = false
        return footerView
    }()
    
    private lazy var footerVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        footerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(footerHorizontalTopStackView)
        stackView.addArrangedSubview(footerHorizontalBottomStackView)
        return stackView
    }()
    
    private lazy var footerHorizontalTopStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(onlyTokenButton)
        stackView.addArrangedSubview(onlyCoinsButton)
        return stackView
    }()
    
    private lazy var onlyTokenButton: UIButton = {
        let button = UIButton()
        button.setTitle(CryptoFilter.token, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = .filterTopButton
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(
            UIAction { [unowned self] _ in
                self.viewModel?.toggleFilter(.token)
            },
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var onlyCoinsButton: UIButton = {
        let button = UIButton()
        button.setTitle(CryptoFilter.coins, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = .filterTopButton
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(
            UIAction { [unowned self] _ in
                self.viewModel?.toggleFilter(.coins)
            },
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var activeCryptosButton: UIButton = {
        let button = UIButton()
        button.setTitle(CryptoFilter.active, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = .filterTopButton
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(
            UIAction { [unowned self] _ in
                self.viewModel?.toggleFilter(.active)
            },
            for: .touchUpInside
        )
        return button
    }()
    
    lazy var inactiveCryptosButton: UIButton = {
        let button = UIButton()
        button.setTitle(CryptoFilter.inactive, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = .filterTopButton
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(
            UIAction { [unowned self] _ in
                self.viewModel?.toggleFilter(.inactive)
            },
            for: .touchUpInside
        )
        return button
    }()
    
    lazy var newCryptoButton: UIButton = {
        let button = UIButton()
        button.setTitle(CryptoFilter.new, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = .filterTopButton
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addAction(
            UIAction { [unowned self] _ in
                self.viewModel?.toggleFilter(.new)
            },
            for: .touchUpInside
        )
        return button
    }()
    
    lazy var footerHorizontalBottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillProportionally
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(activeCryptosButton)
        stackView.addArrangedSubview(inactiveCryptosButton)
        stackView.addArrangedSubview(newCryptoButton)
        return stackView
    }()
    
    private lazy var searchView: UIView = {
        let searchView = UIView()
        searchView.backgroundColor = .primaryTheme
        self.view.addSubview(searchView)
        searchView.translatesAutoresizingMaskIntoConstraints = false
        searchView.clipsToBounds = true
        return searchView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.tableFooterView = UIView()
        return tableView
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        self.view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        return activityIndicator
    }()
    
    private lazy var searchBar: UISearchBar = {
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
        return searchBar
    }()
    
    private lazy var searchViewHeightConstraint: NSLayoutConstraint = {
        searchView.heightAnchor.constraint(equalToConstant: 0)
    }()
    
    func inject(viewModel: HomeViewModel, coordinator: HomeCoordinator? = nil) {
        self.viewModel = viewModel
        self.coordinator = coordinator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .background
        
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
        
        viewModel.$activeFilters
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] activeFilters in
                self.onlyTokenButton.apply(shadow: .remove)
                self.onlyCoinsButton.apply(shadow: .remove)
                self.inactiveCryptosButton.apply(shadow: .remove)
                self.activeCryptosButton.apply(shadow: .remove)
                self.newCryptoButton.apply(shadow: .remove)
                
                if activeFilters.contains(.coins) {
                    self.onlyCoinsButton.apply(shadow: .shadow(color: .black, opacity: 1, offset: CGSize(width: 0, height: 2), radius: 4))
                } else if activeFilters.contains(.token) {
                    self.onlyTokenButton.apply(shadow: .shadow(color: .black, opacity: 1, offset: CGSize(width: 0, height: 2), radius: 4))
                }
                
                if activeFilters.contains(.active) {
                    self.activeCryptosButton.apply(shadow: .shadow(color: .black, opacity: 1, offset: CGSize(width: 0, height: 2), radius: 4))
                } else if activeFilters.contains(.inactive) {
                    self.inactiveCryptosButton.apply(shadow: .shadow(color: .black, opacity: 1, offset: CGSize(width: 0, height: 2), radius: 4))
                }
                
                if activeFilters.contains(.new) {
                    self.newCryptoButton.apply(shadow: .shadow(color: .black, opacity: 1, offset: CGSize(width: 0, height: 2), radius: 4))
                }
            }
            .store(in: &cancellables)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        setHeaderViewConstraints()
        setFooterViewConstraints()
        setBodyViewConstraints()
    }
}

extension HomeViewController {
    private func setHeaderViewConstraints() {
        headerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: self.view.safeAreaInsets.top + 50).isActive = true
        
        headerView.bottomAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 10).isActive = true
        headerTitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
        
        searchButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        headerView.bottomAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 5).isActive = true
        headerView.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor, constant: 16).isActive = true
    }
    
    private func setFooterViewConstraints() {
        footerView.heightAnchor.constraint(equalToConstant: 122 + self.view.safeAreaInsets.bottom).isActive = true
        footerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        footerVerticalStackView.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 16).isActive = true
        footerVerticalStackView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16).isActive = true
        footerView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: footerVerticalStackView.bottomAnchor, constant: 16).isActive = true
        footerView.trailingAnchor.constraint(equalTo: footerVerticalStackView.trailingAnchor, constant: 16).isActive = true
    }
    
    private func setBodyViewConstraints() {
        searchViewHeightConstraint.isActive = true
        searchView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        searchView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        searchView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        searchBar.topAnchor.constraint(equalTo: searchView.topAnchor).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: searchView.leadingAnchor, constant: 8).isActive = true
        searchView.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        searchView.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 8).isActive = true
        
        tableView.topAnchor.constraint(equalTo: searchView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.footerView.topAnchor).isActive = true
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
            self.viewModel?.filterText = searchText.lowercased()
        }
        dispatchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: workItem)
    }
}

#Preview {
    HomeViewController()
}
