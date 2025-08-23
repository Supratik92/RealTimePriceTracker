//
//  ErrorRecoveryService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

protocol ErrorRecoveryService: AnyObject {
    func shouldRetry(error: NetworkError, attemptCount: Int) -> Bool
    func getRetryDelay(for attemptCount: Int) -> TimeInterval
}
