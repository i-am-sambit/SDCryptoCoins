//
//  Serialized.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 22/10/24.
//

import Foundation

@propertyWrapper
struct Serialized<T: Decodable>: Decodable {
    var wrappedValue: T
    var key: String?
    
    init(wrappedValue: T, _ key: String? = nil) {
        self.wrappedValue = wrappedValue
        self.key = key
    }
    
    // Initialize from a decoder (decode the property from the JSON)
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CustomCodingKeys.self)
        
        // Use the custom key if available, otherwise the last coding path component
        let codingKey = key ?? decoder.codingPath.last?.stringValue ?? ""
        
        // Decode the property using the key (custom or inferred)
        self.wrappedValue = try container.decode(T.self, forKey: CustomCodingKeys(stringValue: codingKey)!)
        
        // Assign the key
        self.key = codingKey
    }
    
    // Helper to dynamically create custom coding keys
    struct CustomCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int? { return nil }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        
        init?(intValue: Int) {
            return nil
        }
    }
}
