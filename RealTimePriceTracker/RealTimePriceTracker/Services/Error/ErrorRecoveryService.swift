//
//  ErrorRecoveryService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

protocol ErrorRecoveryService: AnyObject {
    func attemptRecovery(from error: NetworkError, attemptCount: Int) async throws
    func shouldRetry(error: NetworkError, attemptCount: Int) -> Bool
}
