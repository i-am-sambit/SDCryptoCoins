//
//  Constants.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 23/10/24.
//

import Foundation

enum CryptoFilter {
    static let active = "Active Crypto"
    static let inactive = "Inactive Cryptos"
    static let token = "Tokens"
    static let coins = "Coins"
    static let new = "New Cryptos"
}

struct CryptoFilterOptions: OptionSet {
    let rawValue: Int

    static let token = CryptoFilterOptions(rawValue: 1 << 0)
    static let coins = CryptoFilterOptions(rawValue: 1 << 1)
    static let active = CryptoFilterOptions(rawValue: 1 << 2)
    static let inactive = CryptoFilterOptions(rawValue: 1 << 3)
    static let new = CryptoFilterOptions(rawValue: 1 << 4)
}
