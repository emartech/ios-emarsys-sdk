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
        try await testRetryable.retry()

        XCTAssertEqual(testRetryable.counter, 5)
    }

    func testRetry_shouldRetry_givenTimes() async throws {
        try await testRetryable.retry(3)

        XCTAssertEqual(testRetryable.counter, 3)
    }

    func testRetry_shouldThrowError_after_5_Times_byDefault() async throws {
        do {
            try await testRetryable.retryFail()
        } catch {
            XCTAssertTrue(error.self is TestError)
        }

        XCTAssertEqual(testRetryable.counter, 5)
    }

    func testRetry_shouldThrowError_after_retryCountIsReached() async throws {
        do {
            try await testRetryable.retryFail(3)
        } catch {
            XCTAssertTrue(error.self is TestError)
        }

        XCTAssertEqual(testRetryable.counter, 3)
    }

    func testRetry_shouldWaitForGivenTimeInterval() async throws {
        let retryCount = 3
        let delay: Double = 2
        let expectedMinDuration = 2 + 2 * 2
        let expectedMaxDuration = 2 + 2 * 2 + 1
        let clock = ContinuousClock()

        let result = try await clock.measure {
            try await testRetryable.retry(retryCount, delay)
        }

        XCTAssertTrue(expectedMinDuration...expectedMaxDuration ~= Int(result.components.seconds))
        XCTAssertEqual(testRetryable.counter, 3)
    }
}

class TestRetrier: Retrier {
    var counter: Int = 0

    func retry(_ retryCount: Int = 5, _ retryDelay: TimeInterval = 2) async throws {
        try await retry(retryCount, retryDelay) {
            try logic(retryCount)
        }
    }

    func retryFail(_ retryCount: Int = 5) async throws {
        try await retry(retryCount) {
            try failing()
        }
    }

    private func logic(_ retryCount: Int = 5) throws {
        counter += 1
        if counter < retryCount {
            throw TestError()
        }
    }

    private func failing() throws {
        counter += 1
        throw TestError()
    }
}

class TestError: Error {
}
