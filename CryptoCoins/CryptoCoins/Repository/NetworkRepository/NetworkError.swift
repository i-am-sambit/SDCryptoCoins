//
//  NetworkError.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 22/10/24.
//

import Foundation

enum NetworkError: Error {
    case urlError(URLError)
    case decodingError(DecodingError)
    case none
}
