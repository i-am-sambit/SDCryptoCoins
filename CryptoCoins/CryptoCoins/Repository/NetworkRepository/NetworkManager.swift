//
//  NetworkManager.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 22/10/24.
//

import Foundation

// NetworkManager with URLCache
final class NetworkManager: NSObject {
    private let cache: URLCache
    private let session: URLSession
    private let rechability: Rechable
    private let retryPolicy = RetryPolicy.default
    
    /// Description
    ///
    /// 10 MB memory cache
    /// 50 MB disk cache
    /// - Parameters:
    ///   - connectivityChecker: connectivityChecker description
    ///   - cache: cache description
    init(
        rechability: Rechable = Rechability(),
        cache: URLCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,
            diskCapacity: 50 * 1024 * 1024,
            diskPath: "networkCache"
        ),
        config: URLSessionConfiguration = URLSessionConfiguration.default
    ) {
        self.rechability = rechability
        
        // Configure URLCache with a memory and disk limit
        self.cache = cache
        
        config.urlCache = cache
        config.requestCachePolicy = .reloadIgnoringLocalCacheData // Cache policy
        session = URLSession(configuration: config)
    }
    
    func perform<T: Decodable>(request: Request) async throws(NetworkError) -> T {
        guard rechability.isConnected else {
            throw .urlError(URLError(.notConnectedToInternet))
        }
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
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw URLError(.badServerResponse)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
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

extension NetworkManager: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            return (.cancelAuthenticationChallenge, nil)
        }
        
        var error: CFError?
        let isTrusted = SecTrustEvaluateWithError(serverTrust, &error)
        
        guard isTrusted else {
            return (.cancelAuthenticationChallenge, nil)
        }
        
        guard let serverCertificateChain = SecTrustCopyCertificateChain(serverTrust),
                CFArrayGetCount(serverCertificateChain) > 0 else {
            return (.cancelAuthenticationChallenge, nil)
        }
        
        // Retrieve the first certificate in the chain
        let serverCertificate = unsafeBitCast(CFArrayGetValueAtIndex(serverCertificateChain, 0), to: SecCertificate.self)
        
        // Extract data from the server's certificate
        let serverCertificateData = SecCertificateCopyData(serverCertificate) as Data
        
        // Load the local certificate data
        guard let localCertPath = Bundle.main.path(forResource: "myserver", ofType: "cer"),
              let localCertData = NSData(contentsOfFile: localCertPath) as Data? else {
            return (.cancelAuthenticationChallenge, nil)
        }
        
        // Compare the server certificate with the local pinned certificate
        guard localCertData == serverCertificateData else {
            return (.cancelAuthenticationChallenge, nil)
        }
        
        return (.useCredential, URLCredential(trust: serverTrust))
    }
}
