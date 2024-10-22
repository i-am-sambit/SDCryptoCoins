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
    private var tableView: UITableView!
    
    private weak var coordinator: HomeCoordinator?
    private var viewModel: HomeViewModel?
    
    private var cancellables = Set<AnyCancellable>()
    
    var safeArea: UIEdgeInsets {
        let window = UIApplication.shared.connectedScenes.compactMap { ($0 as? UIWindowScene)?.keyWindow }.last
        return window?.safeAreaInsets ?? .zero
    }
    
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
        
        viewModel.fetchCryptoCoins()
    }
}

extension HomeViewController {
    private func createView() {
        self.view.backgroundColor = .background
        createHeaderView()
        createListView()
        createFilterView()
    }
    
    private func createHeaderView() {
        headerView = UIView()
        headerView.backgroundColor = .primaryTheme
        self.view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: safeArea.top + 50).isActive = true
        
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
        
        searchButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        searchButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        headerView.bottomAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 5).isActive = true
        headerView.trailingAnchor.constraint(equalTo: searchButton.trailingAnchor, constant: 16).isActive = true
    }
    
    private func createFilterView() {
        let footerView = UIView()
        footerView.backgroundColor = .filterBackground
        self.view.addSubview(footerView)
        footerView.insetsLayoutMarginsFromSafeArea = true
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.heightAnchor.constraint(equalToConstant: 122 + safeArea.bottom).isActive = true
        footerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        footerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        footerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.spacing = 10
        verticalStackView.distribution = .fillEqually
        footerView.addSubview(verticalStackView)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        verticalStackView.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 16).isActive = true
        verticalStackView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16).isActive = true
        footerView.bottomAnchor.constraint(equalTo: verticalStackView.bottomAnchor, constant: safeArea.bottom + 16).isActive = true
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
        
        let inactiveCoinsButton = UIButton()
        inactiveCoinsButton.setTitle("Inactive coins", for: .normal)
        inactiveCoinsButton.setTitleColor(.black, for: .normal)
        inactiveCoinsButton.titleLabel?.font = .systemFont(ofSize: 14)
        inactiveCoinsButton.backgroundColor = .filterTopButton
        inactiveCoinsButton.layer.cornerRadius = 20
        horizontaltopStackView.addArrangedSubview(inactiveCoinsButton)
        inactiveCoinsButton.translatesAutoresizingMaskIntoConstraints = false
        
        let onlyTokenButton = UIButton()
        onlyTokenButton.setTitle("Only Tokens", for: .normal)
        onlyTokenButton.setTitleColor(.black, for: .normal)
        onlyTokenButton.titleLabel?.font = .systemFont(ofSize: 14)
        onlyTokenButton.backgroundColor = .filterTopButton
        onlyTokenButton.layer.cornerRadius = 20
        horizontaltopStackView.addArrangedSubview(onlyTokenButton)
        onlyTokenButton.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalBottomStackView = UIStackView()
        horizontalBottomStackView.axis = .horizontal
        horizontalBottomStackView.spacing = 10
        horizontalBottomStackView.distribution = .fillProportionally
        verticalStackView.addArrangedSubview(horizontalBottomStackView)
        horizontalBottomStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let onlyCoinsButton = UIButton()
        onlyCoinsButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        onlyCoinsButton.setTitle("Active coins", for: .normal)
        onlyCoinsButton.setTitleColor(.black, for: .normal)
        onlyCoinsButton.titleLabel?.font = .systemFont(ofSize: 14)
        onlyCoinsButton.backgroundColor = .filterBottomButton
        onlyCoinsButton.layer.cornerRadius = 20
        horizontalBottomStackView.addArrangedSubview(onlyCoinsButton)
        onlyCoinsButton.translatesAutoresizingMaskIntoConstraints = false
        
        let newCryptoButton = UIButton()
        newCryptoButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
        newCryptoButton.setTitle("Inactive coins", for: .normal)
        newCryptoButton.setTitleColor(.black, for: .normal)
        newCryptoButton.titleLabel?.font = .systemFont(ofSize: 14)
        newCryptoButton.backgroundColor = .filterBottomButton
        newCryptoButton.layer.cornerRadius = 20
        horizontalBottomStackView.addArrangedSubview(newCryptoButton)
        newCryptoButton.translatesAutoresizingMaskIntoConstraints = false
        
        let spacerView = UIView()
        horizontalBottomStackView.addArrangedSubview(spacerView)
        spacerView.translatesAutoresizingMaskIntoConstraints = false
        spacerView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    private func createListView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.estimatedRowHeight = UITableView.automaticDimension
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "HomeTableViewCell")
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.tableFooterView = UIView()
        
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: safeArea.bottom).isActive = true
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.cryptoCoins.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTableViewCell", for: indexPath) as! HomeTableViewCell
        cell.cryptoCoin = viewModel?.cryptoCoins[indexPath.row]
        return cell
    }
}

#Preview {
    HomeViewController()
}
