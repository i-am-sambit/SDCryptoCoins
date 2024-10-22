//
//  NetworkManager.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 22/10/24.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession
    private let cache: URLCache
    
    private init() {
        // Configure cache: 10 MB memory cache and 50 MB disk cache
        cache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,
            diskCapacity: 50 * 1024 * 1024,
            diskPath: nil
        )
        
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .reloadIgnoringLocalCacheData // Cache policy
        session = URLSession(configuration: config)
    }
    
    func perform<T: Decodable>(request: Request) async throws(NetworkError) -> T {
        guard let url = URL(string: request.endpoint) else {
            throw .urlError(URLError(.badURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        if let headers = request.headers {
            for (key, value) in headers {
                urlRequest.setValue(value, forHTTPHeaderField: key)
            }
        }
        urlRequest.httpBody = request.body
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            return try parse(data: data)
        } catch let error as URLError {
            guard let cachedData = loadCachedResponse(for: request) else {
                throw .urlError(error)
            }
            do {
                return try parse(data: cachedData)
            } catch let error as DecodingError {
                throw NetworkError.decodingError(error)
            } catch {
                throw NetworkError.urlError(URLError(.unknown))
            }
        } catch let error as DecodingError {
            throw .decodingError(error)
        } catch {
            throw .urlError(URLError(.unknown))
        }
    }
    
    // Helper function to create a URLRequest from APIRequest
    private func loadCachedResponse(for request: Request) -> Data? {
        guard let url = URL(string: request.endpoint) else { return nil }
        let urlRequest = URLRequest(url: url)
        
        // Retrieve the cached response from the cache
        if let cachedResponse = cache.cachedResponse(for: urlRequest) {
            return cachedResponse.data
        }
        return nil
    }
    
    private func parse<T: Decodable>(data: Data) throws -> T {
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        return decodedData
    }
}
