//
//  PriceGeneratorError.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

enum PriceGeneratorError: Error, LocalizedError {
    case alreadyGenerating
    case generationFailed(String)
    case webSocketNotAvailable

    var errorDescription: String? {
        switch self {
        case .alreadyGenerating:
            return LocalizationKeys.Errors.Generator.alreadyGenerating.localized()
        case .generationFailed(let message):
            return LocalizationKeys.Errors.Generator.generationFailed.localized() + ": \(message)"
        case .webSocketNotAvailable:
            return LocalizationKeys.Errors.Generator.websocketUnavailable.localized()
        }
    }
}
