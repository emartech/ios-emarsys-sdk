//
//
// Copyright © 2023. Emarsys-Technologies Kft. All rights reserved.
//

import Foundation

protocol Retrier {
    func retry<T>(_ retryCount: Int, _ retryDelay: TimeInterval, _ shouldRetry: ((T) throws -> Bool)?, logic: () async throws -> T) async throws -> T
}

extension Retrier {
    
    func retry<T>(_ retryCount: Int = 5, _ retryDelay: TimeInterval = 2, _ shouldRetry: ((T) throws -> Bool)? = nil, logic: () async throws -> T) async throws -> T {
        var retryError: Error!
        
        for i in 0..<retryCount {
            do {
                let result = try await logic()
                if let shouldRetry = shouldRetry, try shouldRetry(result) {
                    continue
                }
                return result
            } catch {
                retryError = error
                let oneSecond = TimeInterval(1_000_000_000)
                let delay = UInt64(Int(oneSecond * retryDelay) * (i + 1))
                try await Task<Never, Never>.sleep(nanoseconds: delay)

                continue
            }
        }
        if retryError == nil {
          retryError = Errors.retryLimitReached(message: "Retry limit has been reached with retry count \(retryCount)")
        }
        throw retryError
    }
}
