//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

@SdkActor
struct SecStore {
    
    func put(data: Data?, key: String, accessGroup: String?) async throws {
        var query = [String: Any]()
        query[kSecAttrAccount as String] = key
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        query[kSecValueData as String] = data
        query[kSecAttrAccessGroup as String] = accessGroup
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw Errors.storingValueFailed("storingValueFailed".localized(with: "Key: \(key) OSStatus: \(status)"))
        }
    }

    func get(key: String, accessGroup: String?) async throws -> Data? {
        var query = [String: Any]()
        query[kSecAttrAccount as String] = key
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        query[kSecAttrAccessGroup as String] = accessGroup
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        // TODO: handle not found
        
        guard status == errSecSuccess else {
            throw Errors.retrievingValueFailed("retrievingValueFailed".localized(with: "Key: \(key) OSStatus: \(status)"))
        }
        
        guard let data = item as? Data else {
            // TODO: different error
            throw Errors.retrievingValueFailed("retrievingValueFailed".localized(with: "Key: \(key) OSStatus: \(status)"))
        }
        return data
    }
    
}
