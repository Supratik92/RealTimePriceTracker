//
//  NetworkErrorRecovery.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

final class NetworkErrorRecovery: ErrorRecoveryService {
    private let logger: any Logger

    init(logger: any Logger) {
        self.logger = logger
    }

    func shouldRetry(error: NetworkError, attemptCount: Int) -> Bool {
        return NetworkRetryStrategy.shouldRetry(error: error, attemptCount: attemptCount)
    }

    func getRetryDelay(for attemptCount: Int) -> TimeInterval {
        return NetworkRetryStrategy.getRetryDelay(for: attemptCount)
    }
}
