//
//  MockStockDataService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Foundation

final class MockStockDataService: StockDataService {
    var symbols: [StockSymbol] = StockSymbol.sampleSymbols
    var shouldFailUpdate = false

    func getAllSymbols() async -> [StockSymbol] {
        return symbols
    }

    func getSymbol(by code: String) async -> StockSymbol? {
        return symbols.first { $0.symbol.lowercased() == code.lowercased() }
    }

    func updateSymbolPrice(symbol: StockSymbol, newPrice: Double) async -> Result<StockSymbol, StockDataError> {
        if shouldFailUpdate {
            return .failure(.updateFailed("Mock update failed"))
        }

        guard ValidationHelpers.validatePrice(newPrice) else {
            return .failure(.invalidPrice(newPrice))
        }

        var updatedSymbol = symbol
        updatedSymbol.previousPrice = updatedSymbol.currentPrice
        updatedSymbol.currentPrice = newPrice
        updatedSymbol.lastUpdated = Date()

        return .success(updatedSymbol)
    }
}
