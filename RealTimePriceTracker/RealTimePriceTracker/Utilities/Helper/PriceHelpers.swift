//
//  PriceHelpers.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

struct PriceHelpers {
    static func generateRandomPriceChange(for currentPrice: Double) -> Double {
        let volatility = Constants.PriceGeneration.priceVolatility
        let randomChange = Double.random(in: -volatility...volatility)
        return max(Constants.PriceGeneration.minimumPrice, currentPrice * (1 + randomChange))
    }

    static func createPriceUpdate(symbol: String, price: Double) -> PriceUpdate {
        return PriceUpdate(
            symbol: symbol,
            price: price,
            timestamp: DateFormatter.isoFormatter.string(from: Date())
        )
    }
}
