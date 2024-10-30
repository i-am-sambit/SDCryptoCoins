//
//  Rechability.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 26/10/24.
//

import Foundation

// Protocol to check Internet Connectivity
protocol Rechable {
    var isConnected: Bool { get }
}

// Basic Connectivity Checker
class Rechability: Rechable {
    var isConnected: Bool {
        // Replace this with actual reachability code
        // For testing, you can return true/false as needed
        return true
    }
}
