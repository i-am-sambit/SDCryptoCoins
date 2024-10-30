//
//  RetryPolicy.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 26/10/24.
//

import Foundation

struct RetryPolicy {
    let maxRetryCount: Int
    let retryableStatusCode: [Int]
    let delayInterval: TimeInterval
    
    static let `default` = RetryPolicy(maxRetryCount: 3, retryableStatusCode: [500, 502, 503, 504], delayInterval: 2.0)
}
