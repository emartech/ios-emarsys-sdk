//
//
// Copyright © 2022. Emarsys-Technologies Kft. All rights reserved.
//


import Foundation

struct DefaultSecureStorage: SecureStorage {

    let encoder: JSONEncoder
    let decoder: JSONDecoder
    
    func put<T: Codable>(item: T?, key: String, accessGroup: String? = nil) throws {
        var data: Data?
        
        do {
            data = try encoder.encode(item)
            
            var query = [String: Any]()
            query[kSecAttrAccount as String] = key
            query[kSecClass as String] = kSecClassGenericPassword
            query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            query[kSecValueData as String] = data
            query[kSecAttrAccessGroup as String] = accessGroup
            
            try storeItem(query: query)
        } catch {
            // TODO LOG
            throw Errors.TypeError.mappingFailed(parameter: String(describing: item), toType: String(describing: Data.self))
        }
    }
    
    func get<T: Codable>(key: String, accessGroup: String? = nil) throws -> T? {
        var query = [String: Any]()
        query[kSecAttrAccount as String] = key
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        query[kSecAttrAccessGroup as String] = accessGroup
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            throw Errors.StorageError.retrievingValueFailed(key: key, osStatus: String(describing: status))
        }
        guard let resultDict = item as? Dictionary<String, Any> else {
            throw Errors.TypeError.mappingFailed(parameter: String(describing: item), toType: String(describing: Dictionary<String, Any>.self))
        }
        guard let data = resultDict[kSecValueData as String] as? Data else {
            throw Errors.TypeError.mappingFailed(parameter: String(describing: resultDict[kSecValueData as String]), toType: String(describing: Data.self))
        }
        return try decoder.decode(T.self, from: data)
    }
    
    private func storeItem(query: [String: Any]) throws {
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status != errSecSuccess {
            try handleStoringError(osStatus: status, query: query)
        }
    }
    
    private func handleStoringError(osStatus: OSStatus, query: [String: Any]) throws {
        if osStatus == errSecDuplicateItem {
            var deleteQuery = query
            deleteQuery.removeValue(forKey: kSecAttrAccessible as String)
            
            SecItemDelete(deleteQuery as CFDictionary)
            
            try storeItem(query: query)
        } else {
            throw Errors.StorageError.storingValueFailed(key : String(describing: query[kSecAttrAccount as String]), osStatus: String(describing: osStatus))
        }
    }
    
    subscript<T: Codable>(key: String) -> T? {
        get {
            return try? get(key: key, accessGroup: nil)
        }
        set {
            try? put(item: newValue, key: key, accessGroup: nil)
        }
    }
}
