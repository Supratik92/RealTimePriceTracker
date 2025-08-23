//
//  CoordinatorTests.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import XCTest
import Combine
@testable import RealTimePriceTracker

final class CoordinatorTests: XCTestCase {
    var coordinator: AppCoordinator!
    var mockLogger: MockLogger!

    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        Task {
            coordinator = await AppCoordinator(logger: mockLogger)
        }
    }

    override func tearDown() {
        coordinator = nil
        mockLogger = nil
        super.tearDown()
    }

    func testInitialState() async throws {
        Task { @MainActor in
            XCTAssertTrue(coordinator.path.isEmpty)
            XCTAssertNil(coordinator.selectedSymbol)
        }
    }

    func testNavigateToSymbolDetail() async throws {
        let testSymbol = StockSymbol.sampleSymbols.first!
        Task { @MainActor in
            await coordinator.navigate(to: .symbolDetail(testSymbol))
            XCTAssertEqual(coordinator.path.count, 1)
            XCTAssertEqual(coordinator.selectedSymbol?.symbol, testSymbol.symbol)
        }
    }

    func testGoBack() async throws {
        let testSymbol = StockSymbol.sampleSymbols.first!

        Task { @MainActor in
            // Navigate somewhere first
            await coordinator.navigate(to: .symbolDetail(testSymbol))
            XCTAssertEqual(coordinator.path.count, 1)

            // Go back
            await coordinator.goBack()
            XCTAssertEqual(coordinator.path.count, 0)
        }
    }
}
