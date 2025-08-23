//
//  ModelTests.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import XCTest
import Combine
@testable import RealTimePriceTracker

final class ModelTests: XCTestCase {

    func testStockSymbolPriceCalculations() {
        var symbol = StockSymbol(
            symbol: "TEST",
            name: "Test Company",
            description: "Test description",
            currentPrice: 110.0,
            previousPrice: 100.0,
            lastUpdated: Date()
        )

        XCTAssertEqual(symbol.priceChange, 10.0)
        XCTAssertEqual(symbol.priceChangePercentage, 10.0)
        XCTAssertEqual(symbol.priceDirection, .up)

        symbol.currentPrice = 95.0
        XCTAssertEqual(symbol.priceChange, -5.0)
        XCTAssertEqual(symbol.priceChangePercentage, -5.0)
        XCTAssertEqual(symbol.priceDirection, .down)

        symbol.currentPrice = 100.0
        XCTAssertEqual(symbol.priceChange, 0.0)
        XCTAssertEqual(symbol.priceChangePercentage, 0.0)
        XCTAssertEqual(symbol.priceDirection, .neutral)
    }

    func testPriceUpdateCodable() {
        let update = PriceUpdate(symbol: "TEST", price: 123.45, timestamp: "2025-08-23T10:30:00Z")

        do {
            let encoded = try JSONEncoder().encode(update)
            let decoded = try JSONDecoder().decode(PriceUpdate.self, from: encoded)

            XCTAssertEqual(decoded.symbol, update.symbol)
            XCTAssertEqual(decoded.price, update.price)
            XCTAssertEqual(decoded.timestamp, update.timestamp)
        } catch {
            XCTFail("PriceUpdate should be Codable: \(error)")
        }
    }
}
