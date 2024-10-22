//
//  CryptoCointDM.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 22/10/24.
//

import Foundation
import UIKit

enum CoinType: String, Decodable {
    case coin
    case token
}

struct CryptoCoinDM {
    let name: String
    let symbol: String
    let isNew: Bool
    let isActive: Bool
    let type: CoinType
    
    var icon: UIImage {
        if isActive, type == .coin {
            return .activeCryptoCoin
        } else if isActive, type == .token {
            return .cryptoToken
        } else {
            return .inactiveCrypto
        }
    }
}

extension CryptoCoinDM: Decodable {
    enum CodingKeys: String, CodingKey {
        case name
        case symbol
        case isNew = "is_new"
        case isActive = "is_active"
        case type
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.symbol = try container.decode(String.self, forKey: .symbol)
        self.isNew = try container.decode(Bool.self, forKey: .isNew)
        self.isActive = try container.decode(Bool.self, forKey: .isActive)
        self.type = try container.decode(CoinType.self, forKey: .type)
    }
}
