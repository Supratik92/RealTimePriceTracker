//
//  PriceUpdate.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

struct PriceUpdate: Codable {
    let symbol: String
    let price: Double
    let timestamp: String

    init(symbol: String, price: Double, timestamp: String) {
        self.symbol = symbol
        self.price = price
        self.timestamp = timestamp
    }
}
