//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//
        

import Foundation
import XCTest

extension XCTestCase {
    
    func assertThrows<ErrorType>(expectedError: ErrorType, expression: () async throws -> ()) async where ErrorType: Error, ErrorType: Equatable {
        do {
            try await expression()
            XCTFail("Expected error wasn't thrown")
        } catch {
            XCTAssertEqual(error as! ErrorType, expectedError)
        }
    }
    
    func tearDownFakes() {
        let selfMirror = Mirror(reflecting: self)
        selfMirror.children.forEach { child in
            if let fake = child.value as? any Faked {
                fake.tearDown()
            }
        }
    }
    
}
