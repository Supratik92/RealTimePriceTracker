//
//  MockStockDataService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Foundation
import Combine

final class MockStockDataService: StockDataService {
    var symbols: [StockSymbol] = StockSymbol.sampleSymbols
    var shouldFailUpdate = false

    func getAllSymbols() -> AnyPublisher<[StockSymbol], Never> {
        return Just(symbols)
            .eraseToAnyPublisher()
    }

    func getSymbol(by code: String) -> AnyPublisher<StockSymbol?, Never> {
        let symbol = symbols.first { $0.symbol.lowercased() == code.lowercased() }
        return Just(symbol)
            .eraseToAnyPublisher()
    }

    func updateSymbolPrice(symbol: StockSymbol, newPrice: Double) -> Result<StockSymbol, StockDataError> {
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
