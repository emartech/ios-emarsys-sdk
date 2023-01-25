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
        
        try storeItem(query: query)
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
        
        guard status == errSecSuccess else {
            throw Errors.StorageError.retrievingValueFailed("retrievingValueFailed".localized(with: "Key: \(key) OSStatus: \(status)"))
        }
        
        guard let resultDict = item as? Dictionary<String, Any> else {
            throw Errors.StorageError.retrievingValueFailed("retrievingValueFailed".localized(with: "Key: \(key). Result can't be read as a Dictionary"))
        }
        
        
        guard let data = resultDict[kSecValueData as String] as? Data else {
            throw Errors.StorageError.retrievingValueFailed("retrievingValueFailed".localized(with: "Key: \(key)"))
        }
        return T.fromData(data)
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
            throw Errors.StorageError.storingValueFailed("storingValueFailed".localized(with: "Key: \(String(describing: query[kSecAttrAccount as String])) OSStatus: \(osStatus)"))
        }
    }
    
    subscript<T: Storable>(key: String, accessGroup: String? = nil) -> T? {
        get {
            return try? get(key: key, accessGroup: accessGroup)
        }
        set {
            try? put(item: newValue, key: key, accessGroup: accessGroup)
        }
    }
}
