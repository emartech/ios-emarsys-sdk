//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation

struct SecureStorage {
    
    func put<T: Storable>(item: T?, key: String, accessGroup: String? = nil) throws {
        var data: Data?
        
        do {
            data = item?.toData()
        } catch {
            // TODO LOG
            throw Errors.dataConversionFailed("convertToDataFailed".localized(with: "item of type: \(T.self) with key: \(key)"))
        }
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

    func get<T: Storable>(key: String, accessGroup: String? = nil) throws -> T? {
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
        return data as? T
    }
    
//    subscript<T: Storable>(key: String, accessGroup: String? = nil) -> T? {
//        get {
//            return try? get(key: key, accessGroup: accessGroup)
//        }
//        set {
//            try? put(item: newValue, key: key, accessGroup: accessGroup)
//        }
//    }
    
}
