//
//  HomeViewModel.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 21/10/24.
//

import Foundation

final class HomeViewModel: ObservableObject {
    @Published
    private(set) var cryptoCoins: [CryptoCointDM] = []
    
    private var cryptoService: CryptoServiceable
    
    init(cryptoService: CryptoServiceable) {
        self.cryptoService = cryptoService
    }
    
    func fetchCryptoCoins() {
        Task {
            do {
                let coins = try await cryptoService.fetchCryptoCoins()
                await MainActor.run {
                    print(coins)
                    self.cryptoCoins = coins
                }
            } catch let NetworkError.urlError(urlError) {
                print("URL Error: \(urlError.localizedDescription)")
            } catch let NetworkError.decodingError(decodingError) {
                print("Decoding Error: \(decodingError.localizedDescription)")
            }
        }
    }
}
