//
//  SymbolDetailViewModelTests.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import XCTest
import Combine
@testable import RealTimePriceTracker

final class SymbolDetailViewModelTests: XCTestCase {
    var viewModel: SymbolDetailViewModel!
    var mockWebSocketService: MockWebSocketService!
    var mockLogger: MockLogger!
    var testSymbol: StockSymbol!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()

        mockLogger = MockLogger()
        mockWebSocketService = MockWebSocketService()
        testSymbol = StockSymbol.sampleSymbols.first!

        viewModel = SymbolDetailViewModel(
            symbol: testSymbol,
            webSocketService: mockWebSocketService,
            logger: mockLogger
        )
    }

    override func tearDown() {
        cancellables.removeAll()
        viewModel = nil
        mockWebSocketService = nil
        mockLogger = nil
        testSymbol = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.symbol.symbol, testSymbol.symbol)
        XCTAssertEqual(viewModel.symbol.name, testSymbol.name)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testPriceUpdateForCorrectSymbol() {
        let expectation = XCTestExpectation(description: "Price updated")
        let originalPrice = viewModel.symbol.currentPrice
        let newPrice = originalPrice + 10.0

        // Monitor symbol changes
        viewModel.$symbol
            .dropFirst()
            .sink { symbol in
                if symbol.currentPrice == newPrice {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Send update for this symbol
        let update = PriceUpdate(symbol: testSymbol.symbol, price: newPrice, timestamp: "2025-08-23T10:30:00Z")
        mockWebSocketService.simulateUpdate(update)

        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(viewModel.symbol.currentPrice, newPrice)
        XCTAssertEqual(viewModel.symbol.previousPrice, originalPrice)
    }

    func testPriceUpdateForDifferentSymbol() {
        let originalPrice = viewModel.symbol.currentPrice

        // Send update for different symbol
        let update = PriceUpdate(symbol: "DIFFERENT", price: 999.99, timestamp: "2025-08-23T10:30:00Z")
        mockWebSocketService.simulateUpdate(update)

        // Price should not change (test async)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.viewModel.symbol.currentPrice, originalPrice)
        }
    }
}
