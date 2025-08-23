//
//  XCTestCase+Extensions.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Foundation
import Combine
import XCTest
@testable import RealTimePriceTracker


extension XCTestCase {
    func waitForCondition(timeout: TimeInterval = 5.0, condition: @escaping () -> Bool) {
        let expectation = XCTestExpectation(description: "Condition met")

        func checkCondition() {
            if condition() {
                expectation.fulfill()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    checkCondition()
                }
            }
        }

        checkCondition()
        wait(for: [expectation], timeout: timeout)
    }

    func expectToEventuallyBe<T: Equatable>(_ keyPath: KeyPath<some Any, T>, equalTo expectedValue: T, timeout: TimeInterval = 5.0) {
        let expectation = XCTestExpectation(description: "Value should eventually be \(expectedValue)")

        DispatchQueue.main.asyncAfter(deadline: .now() + timeout) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }
}

// Tests/TestUtilities/TestConstants.swift
struct TestConstants {
    static let defaultTimeout: TimeInterval = 5.0
    static let shortTimeout: TimeInterval = 1.0
    static let longTimeout: TimeInterval = 10.0

    static let samplePriceUpdate = PriceUpdate(
        symbol: "TEST",
        price: 123.45,
        timestamp: "2025-08-23T10:30:00Z"
    )

    static let sampleSymbols = [
        StockSymbol(symbol: "TEST1", name: "Test Company 1", description: "Test", currentPrice: 100.0, previousPrice: 95.0, lastUpdated: Date()),
        StockSymbol(symbol: "TEST2", name: "Test Company 2", description: "Test", currentPrice: 200.0, previousPrice: 190.0, lastUpdated: Date())
    ]
}
