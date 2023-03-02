//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation
import XCTest

class DictionaryExtensionTests: EmarsysTestCase {
    
    let parentDictionary = [
        "testKey1": "testValue1",
        "testKey2": "testValue2",
        "testKey3": "testValue3",
        "testKey4": "testValue4",
        "testKey5": "testValue5",
        "testKey6": "testValue6",
    ]
    
    let childDictionary = [
        "testKey5": "testValue5",
        "testKey2": "testValue2"
    ]
    
    func testSubDict_shouldReturnTrue() {
        XCTAssertTrue(parentDictionary.subDict(dict: childDictionary))
    }
    
    func testSubDict_shouldReturnFalse() {
        XCTAssertFalse(childDictionary.subDict(dict: parentDictionary))
    }
    
    func testSubDict_shouldReturnFalse_ifSubDictionary_isEmpty() {
        XCTAssertFalse(parentDictionary.subDict(dict: [:]))
    }
}
