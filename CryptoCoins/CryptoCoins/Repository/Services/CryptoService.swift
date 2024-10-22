//
//  CryptoService.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 22/10/24.
//

import Foundation

protocol CryptoServiceable {
    func fetchCryptoCoins() async throws(NetworkError) -> [CryptoCointDM]
}

final class CryptoService: CryptoServiceable {
    func fetchCryptoCoins() async throws(NetworkError) -> [CryptoCointDM] {
        let request = Request(endpoint: "https://37656be98b8f42ae8348e4da3ee3193f.api.mockbin.io/")
        let networkManager = NetworkManager.shared
        return try await networkManager.perform(request: request)
    }
}
