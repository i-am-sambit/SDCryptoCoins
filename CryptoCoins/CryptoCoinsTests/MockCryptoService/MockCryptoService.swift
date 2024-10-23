//
//  MockCryptoService.swift
//  CryptoCoinsTests
//
//  Created by Sambit Prakash Dash on 23/10/24.
//

@testable import CryptoCoins
import Foundation

final class MockCryptoService: CryptoServiceable {
    func fetchCryptoCoins() async throws(NetworkError) -> [CryptoCoinDM] {
        return [
            CryptoCoinDM(name: "Bitcoin", symbol: "BTC", isNew: false, isActive: true, type: .coin),
            CryptoCoinDM(name: "Ethereum", symbol: "ETH", isNew: false, isActive: true, type: .token),
            CryptoCoinDM(name: "Ripple", symbol: "XRP", isNew: false, isActive: false, type: .coin),
            CryptoCoinDM(name: "Cardano", symbol: "ADA", isNew: true, isActive: true, type: .coin),
            CryptoCoinDM(name: "Litecoin", symbol: "LTC", isNew: false, isActive: true, type: .coin),
            CryptoCoinDM(name: "Chainlink", symbol: "LINK", isNew: true, isActive: true, type: .token),
            CryptoCoinDM(name: "Polkadot", symbol: "DOT", isNew: true, isActive: true, type: .coin),
            CryptoCoinDM(name: "Bitcoin Cash", symbol: "BCH", isNew: false, isActive: true, type: .coin),
            CryptoCoinDM(name: "Stellar", symbol: "XLM", isNew: false, isActive: true, type: .coin),
            CryptoCoinDM(name: "Monero", symbol: "XMR", isNew: false, isActive: true, type: .coin)
        ]
    }
    
    
}
