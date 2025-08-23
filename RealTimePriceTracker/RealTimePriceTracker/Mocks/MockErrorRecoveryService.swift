//
//  MockErrorRecoveryService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

final class MockErrorRecoveryService: ErrorRecoveryService {
    var attemptRecoveryCalled = false
    var shouldSucceedRecovery = true

    func attemptRecovery(from error: NetworkError, attemptCount: Int) async throws {
        attemptRecoveryCalled = true

        if !shouldSucceedRecovery {
            throw error
        }

        try await Task.sleep(for: .milliseconds(100))
    }

    func shouldRetry(error: NetworkError, attemptCount: Int) -> Bool {
        return NetworkRetryStrategy.shouldRetry(error: error, attemptCount: attemptCount)
    }
}
