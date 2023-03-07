//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class SecureStorageTests: EmarsysTestCase {
    
    let testKey = "test"
    var secureStorage: DefaultSecureStorage!

    override func setUpWithError() throws {
        secureStorage = DefaultSecureStorage()
    }
    
    func testData() throws {
        let toStore = Data("testData".utf8)
        
        try secureStorage.put(item: toStore, key: testKey)
        
        let result: Data? = try secureStorage.get(key: testKey)
        
        XCTAssertEqual(result, toStore)
    }
    
    func testData_withSubscript() throws {
        let toStore = Data("testData".utf8)
        
        secureStorage[testKey] = toStore
        
        let result: Data? = secureStorage[testKey]
        
        XCTAssertEqual(result, toStore)
    }

    func testString() throws {
        let toStore = "testString"
        
        try secureStorage.put(item: toStore, key: testKey)
        
        let result: String? = try secureStorage.get(key: testKey)
        
        XCTAssertEqual(result, toStore)
    }
    
    func testString_withSubscript() throws {
        let toStore = "testString"
        
        secureStorage[testKey] = toStore
        
        let result: String? = secureStorage[testKey]
        
        XCTAssertEqual(result, toStore)
    }

    func testInt() throws {
        let toStore = 123456
        
        try secureStorage.put(item: toStore, key: testKey)
        
        let result: Int? = try secureStorage.get(key: testKey)
        
        XCTAssertEqual(result, toStore)
    }
    
    func testInt_withSubscript() throws {
        let toStore = 123456
        
        secureStorage[testKey] = toStore
        
        let result: Int? = secureStorage[testKey]
        
        XCTAssertEqual(result, toStore)
    }

    func testBool() throws {
        let toStore = true
        
        try secureStorage.put(item: toStore, key: testKey)
        
        let result: Bool? = try secureStorage.get(key: testKey)
        
        XCTAssertEqual(result, toStore)
    }
    
    func testBool_withSubscript() throws {
        let toStore = true
        
        secureStorage[testKey] = toStore
        
        let result: Bool? = secureStorage[testKey]
        
        XCTAssertEqual(result, toStore)
    }

    func testDictionary() throws {
        let toStore: [String: Any] = [
            "key1": "testString",
            "key2": 123,
            "key3": true,
            "key4": ["1", "2"]
        ]
        
        try secureStorage.put(item: toStore, key: testKey)
        
        let result: [String: Any]? = try secureStorage.get(key: testKey)
        
        XCTAssertTrue(toStore.equals(dict: result!))
    }
    
    func testDictionary_withSubscript() throws {
        let toStore: [String: Any] = [
            "key1": "testString",
            "key2": 123,
            "key3": true,
            "key4": ["1", "2"]
        ]
        
        secureStorage[testKey] = toStore
        
        let result: [String: Any]? = secureStorage[testKey]
        
        XCTAssertTrue(toStore.equals(dict: result!))
    }
}