//
//  LocalStockDataService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

final class LocalStockDataService: StockDataService {

    private let logger: any Logger

    init(logger: any Logger) {
        self.logger = logger
    }

    func getAllSymbols() async -> [StockSymbol] {
        logger.debug("Loading all stock symbols", category: .business)
        return StockSymbol.sampleSymbols
    }

    func getSymbol(by code: String) async -> StockSymbol? {
        logger.debug("Looking up symbol: \(code)", category: .business)
        let symbol = StockSymbol.sampleSymbols.first { $0.symbol.lowercased() == code.lowercased() }

        if symbol == nil {
            logger.warning("Symbol not found: \(code)", category: .business)
        }

        return symbol
    }

    func updateSymbolPrice(symbol: StockSymbol, newPrice: Double) async -> Result<StockSymbol, StockDataError> {
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
