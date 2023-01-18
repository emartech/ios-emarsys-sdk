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
    
}
