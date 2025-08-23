//
//  StockDataService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Combine

protocol StockDataService: AnyObject {
    func getAllSymbols() -> AnyPublisher<[StockSymbol], Never>
    func getSymbol(by code: String) -> AnyPublisher<StockSymbol?, Never>
    func updateSymbolPrice(symbol: StockSymbol, newPrice: Double) -> Result<StockSymbol, StockDataError>
}
