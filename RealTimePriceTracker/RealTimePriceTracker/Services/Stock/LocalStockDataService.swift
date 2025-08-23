//
//  LocalStockDataService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation
import Combine

final class LocalStockDataService: StockDataService {
    private let logger: any Logger

    init(logger: any Logger) {
        self.logger = logger
    }

    func getAllSymbols() -> AnyPublisher<[StockSymbol], Never> {
        logger.debug("Loading all stock symbols", category: .business)
        return Just(StockSymbol.sampleSymbols)
            .eraseToAnyPublisher()
    }

    func getSymbol(by code: String) -> AnyPublisher<StockSymbol?, Never> {
        logger.debug("Looking up symbol: \(code)", category: .business)
        let symbol = StockSymbol.sampleSymbols.first { $0.symbol.lowercased() == code.lowercased() }

        if symbol == nil {
            logger.warning("Symbol not found: \(code)", category: .business)
        }

        return Just(symbol)
            .eraseToAnyPublisher()
    }

    func updateSymbolPrice(symbol: StockSymbol, newPrice: Double) -> Result<StockSymbol, StockDataError> {
        guard ValidationHelpers.validatePrice(newPrice) else {
            logger.error("Invalid price for \(symbol.symbol): \(newPrice)",
                         error: StockDataError.invalidPrice(newPrice),
                         category: .business)
            return .failure(.invalidPrice(newPrice))
        }

        var updatedSymbol = symbol
        let oldPrice = updatedSymbol.currentPrice
        updatedSymbol.previousPrice = oldPrice
        updatedSymbol.currentPrice = newPrice
        updatedSymbol.lastUpdated = Date()

        logger.debug("Updated \(updatedSymbol.symbol) price: \(oldPrice.toCurrency()) -> \(newPrice.toCurrency())", category: .business)
        return .success(updatedSymbol)
    }
}
