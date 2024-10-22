//
//  Request.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 22/10/24.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct Request {
    let endpoint: String
    let method: HTTPMethod
    let headers: [String: String]?
    let body: Data?

    init(endpoint: String, method: HTTPMethod = .get, headers: [String: String]? = nil, body: Data? = nil) {
        self.endpoint = endpoint
        self.method = method
        self.headers = headers
        self.body = body
    }
}
