//
//  CoordinatorTests.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import XCTest
import Combine
@testable import RealTimePriceTracker

final class HelpersTests: XCTestCase {

    func testValidationHelpers() {
        // Price validation
        XCTAssertTrue(ValidationHelpers.validatePrice(100.0))
        XCTAssertTrue(ValidationHelpers.validatePrice(Constants.PriceGeneration.minimumPrice))
        XCTAssertTrue(ValidationHelpers.validatePrice(Constants.PriceGeneration.maximumPrice))

        XCTAssertFalse(ValidationHelpers.validatePrice(-10.0))
        XCTAssertFalse(ValidationHelpers.validatePrice(0.0))
        XCTAssertFalse(ValidationHelpers.validatePrice(.infinity))
        XCTAssertFalse(ValidationHelpers.validatePrice(.nan))

        // Symbol code validation
        XCTAssertTrue(ValidationHelpers.validateSymbolCode("AAPL"))
        XCTAssertTrue(ValidationHelpers.validateSymbolCode("BRK.B"))
        XCTAssertFalse(ValidationHelpers.validateSymbolCode(""))
        XCTAssertFalse(ValidationHelpers.validateSymbolCode("123"))
    }

    func testPriceHelpers() {
        let currentPrice = 100.0
        let newPrice = PriceHelpers.generateRandomPriceChange(for: currentPrice)

        XCTAssertGreaterThanOrEqual(newPrice, Constants.PriceGeneration.minimumPrice)
        XCTAssertTrue(newPrice.isFinite)

        // Test price update creation
        let update = PriceHelpers.createPriceUpdate(symbol: "TEST", price: 123.45)
        XCTAssertEqual(update.symbol, "TEST")
        XCTAssertEqual(update.price, 123.45)
        XCTAssertFalse(update.timestamp.isEmpty)
    }

    func testURLHelpers() {
        let testURL = URL(string: "stocks://symbol/AAPL/extra")!
        let components = URLHelpers.extractPathComponents(from: testURL)

        XCTAssertEqual(components, ["AAPL", "extra"])

        let deepLinkURL = URLHelpers.createDeepLinkURL(for: "TSLA")
        XCTAssertNotNil(deepLinkURL)
        XCTAssertEqual(deepLinkURL?.absoluteString, "stocks://symbol/TSLA")
    }
}
