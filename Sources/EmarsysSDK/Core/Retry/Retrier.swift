//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

protocol Retrier {
    func retry<T>(_ retryCount: Int, _ retryDelay: TimeInterval, logic: () async throws -> T) async throws -> T
}

extension Retrier {

    func retry<T>(_ retryCount: Int = 5, _ retryDelay: TimeInterval = 2, logic: () async throws -> T) async throws -> T {
        var retryError: Error!

        for i in 0..<retryCount {
            do {
                return try await logic()
            } catch {
                retryError = error
                let oneSecond = TimeInterval(1_000_000_000)
                let delay = UInt64(Int(oneSecond * retryDelay) * (i + 1))
                try await Task<Never, Never>.sleep(nanoseconds: delay)

                continue
            }
        }
        throw retryError
    }
}
