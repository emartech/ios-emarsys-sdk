//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class HttpURLResponseTests: XCTestCase {

    func testIsRetryable_shouldBeTrue_withStatus_408() throws {
        
        let testResponse = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 408, httpVersion: nil, headerFields: nil)
        
        XCTAssertTrue(testResponse!.isRetriable())
    }
    
    func testIsRetryable_shouldBeTrue_withStatus_429() throws {
        
        let testResponse = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 429, httpVersion: nil, headerFields: nil)
        
        XCTAssertTrue(testResponse!.isRetriable())
    }
    
    func testIsRetryable_shouldBeTrue_withStatus_3xx() throws {
        
        let testResponse = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 311, httpVersion: nil, headerFields: nil)
        
        XCTAssertTrue(testResponse!.isRetriable())
    }
    
    func testIsRetryable_shouldBeFalse_withStatus_4xx() throws {
        
        let testResponse = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 433, httpVersion: nil, headerFields: nil)
        
        XCTAssertFalse(testResponse!.isRetriable())
    }
    
    func testIsRetryable_shouldBeTrue_withStatus_500() throws {
        
        let testResponse = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 500, httpVersion: nil, headerFields: nil)
        
        XCTAssertTrue(testResponse!.isRetriable())
    }

}
