//
//  StockDataService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

protocol StockDataService: AnyObject {
    func getAllSymbols() async -> [StockSymbol]
    func getSymbol(by code: String) async -> StockSymbol?
    func updateSymbolPrice(symbol: StockSymbol, newPrice: Double) async -> Result<StockSymbol, StockDataError>
}
