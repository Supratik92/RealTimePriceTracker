//
//  NetworkError.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case connectionFailed(String)
    case sendFailed(String)
    case receiveFailed(String)
    case encodingFailed(String)
    case decodingFailed(String)
    case timeout
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return LocalizationKeys.Errors.Network.invalidURL.localized()
        case .connectionFailed(let message):
            return LocalizationKeys.Errors.Network.connectionFailed.localized() + ": \(message)"
        case .sendFailed(let message):
            return LocalizationKeys.Errors.Network.sendFailed.localized() + ": \(message)"
        case .receiveFailed(let message):
            return LocalizationKeys.Errors.Network.receiveFailed.localized() + ": \(message)"
        case .encodingFailed(let message):
            return LocalizationKeys.Errors.Network.encodingFailed.localized() + ": \(message)"
        case .decodingFailed(let message):
            return LocalizationKeys.Errors.Network.decodingFailed.localized() + ": \(message)"
        case .timeout:
            return LocalizationKeys.Errors.Network.timeout.localized()
        case .networkUnavailable:
            return LocalizationKeys.Errors.Network.unavailable.localized()
        }
    }

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.timeout, .timeout),
             (.networkUnavailable, .networkUnavailable):
            return true
        case (.connectionFailed(let lhsMessage), .connectionFailed(let rhsMessage)),
             (.sendFailed(let lhsMessage), .sendFailed(let rhsMessage)),
             (.receiveFailed(let lhsMessage), .receiveFailed(let rhsMessage)),
             (.encodingFailed(let lhsMessage), .encodingFailed(let rhsMessage)),
             (.decodingFailed(let lhsMessage), .decodingFailed(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
