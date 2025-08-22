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

    func updateSymbolPrice(_ symbol: inout StockSymbol, newPrice: Double) async -> Result<Void, StockDataError> {
        guard ValidationHelpers.validatePrice(newPrice) else {
            logger.error("Invalid price for \(symbol.symbol): \(newPrice)",
                         error: StockDataError.invalidPrice(newPrice),
                         category: .business)
            return .failure(.invalidPrice(newPrice))
        }

        let oldPrice = symbol.currentPrice
        symbol.previousPrice = oldPrice
        symbol.currentPrice = newPrice
        symbol.lastUpdated = Date()

        logger.debug("Updated \(symbol.symbol) price: \(oldPrice.toCurrency()) -> \(newPrice.toCurrency())", category: .business)
        return .success(())
    }
}
