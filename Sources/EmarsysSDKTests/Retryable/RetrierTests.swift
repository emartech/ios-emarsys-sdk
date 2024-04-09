//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import XCTest
@testable import EmarsysSDK

final class RetrierTests: XCTestCase {
    var testRetryable: TestRetrier!

    override func setUpWithError() throws {
        testRetryable = TestRetrier()
    }

    func testRetry_shouldRetry_5_times_byDefault() async throws {
        try await testRetryable.retry(5, 0.1)

        XCTAssertEqual(testRetryable.counter, 5)
    }

    func testRetry_shouldRetry_givenTimes() async throws {
        try await testRetryable.retry(3, 0.1)

        XCTAssertEqual(testRetryable.counter, 3)
    }

    func testRetry_shouldThrowError_after_5_Times_byDefault() async throws {
        do {
            try await testRetryable.retryFail(5, 0.1)
        } catch {
            XCTAssertTrue(error.self is TestError)
        }

        XCTAssertEqual(testRetryable.counter, 5)
    }

    func testRetry_shouldThrowError_after_retryCountIsReached() async throws {
        do {
            try await testRetryable.retryFail(3, 0.1)
        } catch {
            XCTAssertTrue(error.self is TestError)
        }

        XCTAssertEqual(testRetryable.counter, 3)
    }

    func testRetry_shouldWaitForGivenTimeInterval() async throws {
        let retryCount = 3
        let delay: Double = 1
        let expectedMinDuration = 1 + 2 * 1
        let expectedMaxDuration = 1 + 2 * 1 + 1
        let clock = ContinuousClock()

        let result = try await clock.measure {
            try await testRetryable.retry(retryCount, delay)
        }

        XCTAssertTrue(expectedMinDuration...expectedMaxDuration ~= Int(result.components.seconds))
        XCTAssertEqual(testRetryable.counter, 3)
    }
    
    func testRetry_shouldRetryNotRetry_ifResult_shouldNotBeRetried() async throws {
        let retryCount = 3
        let delay: Double = 2
        let shouldRetry: (Int) -> Bool = { int in
            return false
        }
        try await testRetryable.withShouldRetry(retryCount, delay, shouldRetry)
        
        XCTAssertEqual(testRetryable.counter, 1)
    }
    
    func testRetry_shouldRetry_ifResult_shouldBeRetried() async throws {
        let retryCount = 3
        let delay: Double = 0.1
        let shouldRetry: (Int) -> Bool = { int in
            return self.testRetryable.counter != retryCount
        }
        try await testRetryable.withShouldRetry(retryCount, delay, shouldRetry)
        
        XCTAssertEqual(testRetryable.counter, 3)
    }
    
    func testRetry_shouldThrow_retryLimitReachedError_ifCounterLimitReached() async throws {
        let retryCount = 3
        let delay: Double = 0.1
        let shouldRetry: (Int) -> Bool = { int in
            return true
        }
        let expectedError = Errors.retryLimitReached(message: "Retry limit has been reached with retry count \(retryCount)")
        
        await assertThrows(expectedError: expectedError) {
            try await testRetryable.withShouldRetry(retryCount, delay, shouldRetry)
        }
    }
}

class TestRetrier: Retrier {
    var counter: Int = 0

    func retry(_ retryCount: Int = 5, _ retryDelay: TimeInterval = 2) async throws {
        try await retry(retryCount, retryDelay) {
            counter += 1
            if counter < retryCount {
                throw TestError()
            }
        }
    }
    
    func retryFail(_ retryCount: Int = 5, _ retryDelay: TimeInterval = 2) async throws {
        try await retry(retryCount, retryDelay) {
            counter += 1
            throw TestError()
        }
    }
    
    func withShouldRetry(_ retryCount: Int = 5, _ retryDelay: TimeInterval = 2, _ shouldRetry: ((Int) -> Bool)? = nil) async throws {
        let _ = try await retry(retryCount, retryDelay, shouldRetry) {
            counter += 1
            return counter
        }
    }
}

class TestError: Error {
}
