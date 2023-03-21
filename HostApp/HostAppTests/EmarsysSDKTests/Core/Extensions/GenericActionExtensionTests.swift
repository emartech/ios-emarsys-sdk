//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

@SdkActor
final class GenericActionExtensionTests: XCTestCase {
    let type = "MECustomEvent"
    let url = "https://www.emarsys.com"
    let actionName = "testName"
    let payload = ["key":"value"]
    let method = "add"
    let value = 2
    let text = "testText"
    
    func testGetSafeName_shouldReturn_name() throws {
        let genericAction = GenericAction(type: type, url: url, name: actionName, payload: payload, method: method, value: value, text: text)
        
        let result = try genericAction.getSafeName()
        
        XCTAssertEqual(result, actionName)
    }
    
    func testGetSafeName_shouldThrow_preconditionFailedError() async throws {
        let genericAction = GenericAction(type: type, url: url, name: nil, payload: payload, method: method, value: value, text: text)
        
        await assertThrows(expectedError: Errors.preconditionFailed(message: "Action name must not be nil")) {
           let _ = try genericAction.getSafeName()
        }
    }
    
    func testGetSafeURL_shouldReturn_url() throws {
        let genericAction = GenericAction(type: type, url: url, name: actionName, payload: payload, method: method, value: value, text: text)
        
        let result = try genericAction.getSafeURL()
        
        XCTAssertEqual(result, URL(string: url)!)
    }
    
    func testGetSafeURL_shouldThrow_preconditionFailedError_ifURL_isNil() async throws {
        let genericAction = GenericAction(type: type, url: nil, name: nil, payload: payload, method: method, value: value, text: text)
        
        await assertThrows(expectedError: Errors.preconditionFailed(message: "Action URL must not be nil")) {
           let _ = try genericAction.getSafeURL()
        }
    }
    
    func testGetSafeURL_shouldThrow_preconditionFailedError_ifURL_isInvalid() async throws {
        let genericAction = GenericAction(type: type, url: "https://ema   rsys.com", name: nil, payload: payload, method: method, value: value, text: text)
        
        await assertThrows(expectedError: Errors.preconditionFailed(message: "Action URL must be valid")) {
           let _ = try genericAction.getSafeURL()
        }
    }
    
    func testGetSafeMethod_shouldReturnMethod() async throws {
        let genericAction = GenericAction(type: type, url: nil, name: nil, payload: nil, method: method, value: value, text: text)
        
        let result = try genericAction.getSafeMethod()
        
        XCTAssertEqual(method, result)
    }
    
    func testGetSafeMethod_shouldThrow_preconditionFailedError_ifMethod_isNil() async throws {
        let genericAction = GenericAction(type: type, url: nil, name: nil, payload: payload, method: nil, value: value, text: text)
        
        await assertThrows(expectedError: Errors.preconditionFailed(message: "Action method must not be nil")) {
           let _ = try genericAction.getSafeMethod()
        }
    }
    
    func testGetSafeValue_shouldReturnValue() async throws {
        let genericAction = GenericAction(type: type, url: nil, name: nil, payload: nil, method: method, value: value, text: text)
        
        let result = try genericAction.getSafeValue()
        
        XCTAssertEqual(value, result)
    }
    
    func testGetSafeValue_shouldThrow_preconditionFailedError_ifValue_isNil() async throws {
        let genericAction = GenericAction(type: type, url: nil, name: nil, payload: payload, method: method, value: nil, text: text)
        
        await assertThrows(expectedError: Errors.preconditionFailed(message: "Action value must not be nil")) {
           let _ = try genericAction.getSafeValue()
        }
    }
    
    func testGetSafeText_shouldReturnText() async throws {
        let genericAction = GenericAction(type: type, url: nil, name: nil, payload: nil, method: method, value: value, text: text)
        
        let result = try genericAction.getSafeText()
        
        XCTAssertEqual(text, result)
    }
    
    func testGetSafeText_shouldThrow_preconditionFailedError_ifText_isNil() async throws {
        let genericAction = GenericAction(type: type, url: nil, name: nil, payload: payload, method: method, value: value, text: nil)
        
        await assertThrows(expectedError: Errors.preconditionFailed(message: "Action text must not be nil")) {
           let _ = try genericAction.getSafeText()
        }
    }
}
