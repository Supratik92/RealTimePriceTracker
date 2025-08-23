//
//  Array+Extension.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

extension Array where Element == StockSymbol {
    func sortedByPrice() -> [StockSymbol] {
        return sorted { $0.currentPrice > $1.currentPrice }
    }
}
