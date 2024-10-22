//
//  HomeViewModel.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 21/10/24.
//

import Foundation

final class HomeViewModel: ObservableObject {
    private var allCoins: [CryptoCoinDM] = []
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var cryptoCoins: [CryptoCoinDM] = []
    @Published private(set) var error: NetworkError = .none
    
    private var cryptoService: CryptoServiceable
    
    init(cryptoService: CryptoServiceable) {
        self.cryptoService = cryptoService
    }
    
    func fetchCryptoCoins() {
        isLoading = true
        Task {
            do {
                let coins = try await cryptoService.fetchCryptoCoins()
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.allCoins = coins
                    self.cryptoCoins = coins
                    self.isLoading = false
                }
            } catch let error as NetworkError {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    func filterOnlyActiveCoins() {
        let filteredCoins = allCoins.filter({ $0.type == .coin && $0.isActive })
        self.cryptoCoins = filteredCoins
    }
    
    func filterOnlyInactiveCoins() {
        let filteredCoins = allCoins.filter({ !$0.isActive })
        self.cryptoCoins = filteredCoins
    }
    
    func filterOnlyNewCoins() {
        let filteredCoins = allCoins.filter({ $0.isNew })
        self.cryptoCoins = filteredCoins
    }
    
    func filterOnlyToken() {
        let filteredCoins = allCoins.filter({ $0.type == .token })
        self.cryptoCoins = filteredCoins
    }
    
    func filterOnlyCoins() {
        let filteredCoins = allCoins.filter({ $0.type == .coin })
        self.cryptoCoins = filteredCoins
    }
    
    func filterCoins(with text: String) {
        guard !text.isEmpty else {
            self.cryptoCoins = allCoins
            return
        }
        let filteredCoins = allCoins.filter({ $0.name.lowercased().contains(text) || $0.symbol.lowercased().contains(text) })
        self.cryptoCoins = filteredCoins
    }
}
