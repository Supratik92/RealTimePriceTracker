//
//  MockErrorRecoveryService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Foundation

final class MockErrorRecoveryService: ErrorRecoveryService {
    var shouldRetryResult = true

    func shouldRetry(error: NetworkError, attemptCount: Int) -> Bool {
        return shouldRetryResult && NetworkRetryStrategy.shouldRetry(error: error, attemptCount: attemptCount)
    }

    func getRetryDelay(for attemptCount: Int) -> TimeInterval {
        return 0.1 // Fast retry for testing
    }
}
