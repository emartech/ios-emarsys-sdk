//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import XCTest
@testable import EmarsysSDK

final class LogEntryTests: EmarsysTestCase {

    func testCreate_shouldCreateLogEntryWithCorrectProperties() throws {
        let testStruct = TestStruct()
        let params: [String: Any]? = [
            "testKey":"testValue"
        ]
        
        let expectedData: [String: Any] = [
            "className": "TestStruct()",
            "methodName": "testCreate_shouldCreateLogEntryWithCorrectProperties()",
            "parameters": [
                "testKey":"testValue"
            ]
        ]
        
       let result =  LogEntry.createMethodNotAllowedEntry(source: testStruct, params: params)
        
        XCTAssertTrue(result.data.equals(dict: expectedData))
    
    }
    
    func testCreate_shouldCreateLogEntryWithoutParams_whenParamsIsNil() throws {
        let testStruct = TestStruct()
        
        let expectedData: [String: Any] = [
            "className": "TestStruct()",
            "methodName": "testCreate_shouldCreateLogEntryWithoutParams_whenParamsIsNil()"
        ]
        
       let result =  LogEntry.createMethodNotAllowedEntry(source: testStruct, params: nil)
        
        XCTAssertTrue(result.data.equals(dict: expectedData))
    
    }

    struct TestStruct {}
}
