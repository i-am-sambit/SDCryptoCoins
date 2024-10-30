//
//  NetworkManagerTestCases.swift
//  CryptoCoinsTests
//
//  Created by Sambit Prakash Dash on 24/10/24.
//

@testable import CryptoCoins
import Testing
import Foundation

class MockRechability: Rechable {
    var isConnected = true
    
    init(isConnected: Bool = true) {
        self.isConnected = isConnected
    }
}

struct NetworkManagerTestCases {
    var jsonData: Data {
        let jsonData = """
        [
          {
            "name": "Bitcoin",
            "symbol": "BTC",
            "is_new": false,
            "is_active": true,
            "type": "coin"
          },
          {
            "name": "Ethereum",
            "symbol": "ETH",
            "is_new": false,
            "is_active": true,
            "type": "token"
          }
        ]
        """.data(using: .utf8)!
        return jsonData
    }
    
    var decodingErrorJsonData: Data {
        let jsonData = """
        [
          {
            "name": "Bitcoin",
            "symbol": "BTC",
            "isNew": false,
            "isActive": true,
            "type": "coin"
          },
          {
            "name": "Ethereum",
            "symbol": "ETH",
            "isNew": false,
            "isActive": true,
            "type": "token"
          }
        ]
        """.data(using: .utf8)!
        return jsonData
    }
    
    init() {
        
    }
    
    @Test("Test Success Response")
    func testSuccessResponse() async throws {
        let connectivityChecker = MockRechability()
        
        let cache = URLCache(memoryCapacity: 5 * 1024 * 1024,
                               diskCapacity: 20 * 1024 * 1024,
                               diskPath: "testNetworkCache")
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        
        // Inject custom cache into NetworkManager
        let networkManager = NetworkManager(rechability: connectivityChecker, cache: cache, config: config)
        cache.removeAllCachedResponses()
        
        // Mock Response
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url.absoluteString == "https://example.com/crypto" else {
                throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            }
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, jsonData)
        }
        
        // Perform the request
        let request = Request(endpoint: "https://example.com/crypto", method: .get)
        let result: [CryptoCoinDM] = try await networkManager.perform(request: request)
        #expect(result.count == 2)
    }
    
    @Test("No Network Connectivity")
    func testNoNetworkConnectivity() async throws {
        let connectivityChecker = MockRechability(isConnected: false)
        let cache = URLCache.shared
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        
        // Inject custom cache into NetworkManager
        let networkManager = NetworkManager(rechability: connectivityChecker, cache: cache, config: config)
        cache.removeAllCachedResponses()
        
        // Perform the request
        let request = Request(endpoint: "https://example.com/crypto", method: .get)
        do {
            let _: [CryptoCoinDM] = try await networkManager.perform(request: request)
        } catch {
            switch error {
                case let .urlError(urlError):
                    #expect(urlError.code == URLError.notConnectedToInternet)
                default:
                    break
            }
        }
    }
    
    @Test("Bad URL")
    func testBadURL() async throws {
        let connectivityChecker = MockRechability()
        
        let cache = URLCache.shared
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        
        // Inject custom cache into NetworkManager
        let networkManager = NetworkManager(rechability: connectivityChecker, cache: cache, config: config)
        cache.removeAllCachedResponses()
        
        // Perform the request
        let request = Request(endpoint: "", method: .get)
        do {
            let _: [CryptoCoinDM] = try await networkManager.perform(request: request)
        } catch {
            switch error {
                case let .urlError(urlError):
                    #expect(urlError.code == URLError.badURL)
                default:
                    break
            }
        }
    }
    
    @Test("Decoding Error")
    func testDecodingError() async throws {
        let connectivityChecker = MockRechability()
        
        let cache = URLCache(memoryCapacity: 5 * 1024 * 1024,
                               diskCapacity: 20 * 1024 * 1024,
                               diskPath: "testNetworkCache")
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [MockURLProtocol.self]
        
        // Inject custom cache into NetworkManager
        let networkManager = NetworkManager(rechability: connectivityChecker, cache: cache, config: config)
        cache.removeAllCachedResponses()
        
        // Mock Response
        MockURLProtocol.requestHandler = { request in
            guard let url = request.url, url.absoluteString == "https://example.com/crypto" else {
                throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            }
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, decodingErrorJsonData)
        }
        
        await #expect(throws: NetworkError.self) {
            // Perform the request
            let request = Request(endpoint: "https://example.com/crypto", method: .get)
            let _: [CryptoCoinDM] = try await networkManager.perform(request: request)
        }
    }
}
