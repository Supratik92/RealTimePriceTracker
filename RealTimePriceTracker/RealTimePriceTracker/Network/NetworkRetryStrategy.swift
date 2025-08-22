//
//  NetworkRetryStrategy.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

struct NetworkRetryStrategy {
    static func shouldRetry(error: NetworkError, attemptCount: Int) -> Bool {
        guard attemptCount < Constants.Network.maxRetryAttempts else {
            return false
        }

        switch error {
        case .timeout, .connectionFailed, .networkUnavailable:
            return true
        case .invalidURL, .encodingFailed, .decodingFailed:
            return false
        default:
            return true
        }
    }

    static func getRetryDelay(for attemptCount: Int) -> TimeInterval {
        let delays = Constants.Network.retryDelays
        return attemptCount < delays.count ? delays[attemptCount] : delays.last ?? Constants.Network.reconnectionDelay
    }
}
