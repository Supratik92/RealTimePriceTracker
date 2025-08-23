//
//  StockFeedViewModelTests.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import XCTest
import Combine
@testable import RealTimePriceTracker

final class StockFeedViewModelTests: XCTestCase {
    var viewModel: StockFeedViewModel!
    var mockWebSocketService: MockWebSocketService!
    var mockPriceGenerator: MockPriceGeneratorService!
    var mockStockDataService: MockStockDataService!
    var mockErrorRecovery: MockErrorRecoveryService!
    var mockLogger: MockLogger!
    var cancellables = Set<AnyCancellable>()

    override func setUp() async throws {
        try await super.setUp()

        mockLogger = MockLogger()
        mockWebSocketService = MockWebSocketService()
        mockPriceGenerator = MockPriceGeneratorService()
        mockStockDataService = MockStockDataService()
        mockErrorRecovery = MockErrorRecoveryService()

        viewModel = StockFeedViewModel(
            webSocketService: mockWebSocketService,
            priceGeneratorService: mockPriceGenerator,
            stockDataService: mockStockDataService,
            errorRecoveryService: mockErrorRecovery,
            logger: mockLogger
        )
    }

    override func tearDown() async throws {
        viewModel.stopTracking()
        cancellables.removeAll()
        viewModel = nil
        try await super.tearDown()
    }

    func testInitialState() {
        XCTAssertFalse(viewModel.isTrackingActive)
        XCTAssertTrue(viewModel.flashingSymbols.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.symbols.count, Constants.UI.minimumSymbolCount)
    }

    func testStartTrackingSuccess() {
        let expectation = XCTestExpectation(description: "Tracking started")

        mockWebSocketService.shouldSucceedConnection = true
        mockPriceGenerator.shouldSucceedGeneration = true

        viewModel.$isTrackingActive
            .dropFirst()
            .sink { isActive in
                if isActive {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.startTracking()

        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(mockWebSocketService.connectCalled)
        XCTAssertTrue(mockPriceGenerator.startGeneratingCalled)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testStartTrackingFailure() {
        let expectation = XCTestExpectation(description: "Error handled")

        mockWebSocketService.shouldSucceedConnection = false
        mockWebSocketService.connectionError = .connectionFailed("Test error")

        viewModel.$errorMessage
            .dropFirst()
            .compactMap { $0 }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.startTracking()

        wait(for: [expectation], timeout: 2.0)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isTrackingActive)
    }

    func testPriceUpdateHandling() {
        let expectation = XCTestExpectation(description: "Price updated")

        viewModel.$symbols
            .dropFirst()
            .sink { symbols in
                if let updatedSymbol = symbols.first(where: { $0.symbol == "AAPL" }),
                   updatedSymbol.currentPrice == 200.0 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        let update = PriceUpdate(symbol: "AAPL", price: 200.0, timestamp: "2025-08-22T10:30:00Z")
        mockWebSocketService.simulateUpdate(update)

        wait(for: [expectation], timeout: 2.0)
    }

    func testSymbolsSortedByPrice() {
        let prices = viewModel.symbols.map { $0.currentPrice }
        let sortedPrices = prices.sorted(by: >)
        XCTAssertEqual(prices, sortedPrices)
    }
}
