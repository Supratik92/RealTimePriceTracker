//
//  NetworkErrorRecovery.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

final class NetworkErrorRecovery: ErrorRecoveryService {

    private let logger: any Logger

    init(logger: any Logger) {
        self.logger = logger
    }

    func attemptRecovery(from error: NetworkError, attemptCount: Int) async throws {
        guard shouldRetry(error: error, attemptCount: attemptCount) else {
            logger.error("Max retry attempts reached for error: \(error)", error: error, category: .network)
            throw error
        }

        let delay = NetworkRetryStrategy.getRetryDelay(for: attemptCount)
        logger.info("Attempting recovery in \(delay) seconds (attempt \(attemptCount + 1))", category: .network)

        try await Task.sleep(for: .seconds(delay))
    }

    func shouldRetry(error: NetworkError, attemptCount: Int) -> Bool {
        return NetworkRetryStrategy.shouldRetry(error: error, attemptCount: attemptCount)
    }
}
