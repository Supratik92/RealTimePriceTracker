//
//  StockDataError.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

enum StockDataError: Error, LocalizedError {
    case symbolNotFound(String)
    case invalidPrice(Double)
    case updateFailed(String)

    var errorDescription: String? {
        switch self {
        case .symbolNotFound(let symbol):
            return LocalizationKeys.Errors.Stock.symbolNotFound.localized() + ": \(symbol)"
        case .invalidPrice(let price):
            return LocalizationKeys.Errors.Stock.invalidPrice.localized() + ": \(price)"
        case .updateFailed(let message):
            return LocalizationKeys.Errors.Stock.updateFailed.localized() + ": \(message)"
        }
    }
}
