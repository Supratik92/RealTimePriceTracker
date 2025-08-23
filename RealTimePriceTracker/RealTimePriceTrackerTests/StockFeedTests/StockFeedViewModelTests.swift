//
//  StockFeedViewModelTests.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import XCTest
@testable import RealTimePriceTracker

@MainActor
final class StockFeedViewModelTests: XCTestCase {
    var viewModel: StockFeedViewModel!
    var mockWebSocketService: MockWebSocketService!
    var mockPriceGenerator: MockPriceGeneratorService!
    var mockStockDataService: MockStockDataService!
    var mockErrorRecovery: MockErrorRecoveryService!
    var mockLogger: MockLogger!

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
        await viewModel.stopTracking()
        viewModel = nil
        try await super.tearDown()
    }

    func testInitialState() async {
        XCTAssertFalse(viewModel.isTrackingActive)
        XCTAssertTrue(viewModel.flashingSymbols.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.symbols.count, Constants.UI.minimumSymbolCount)
    }

    func testStartTrackingSuccess() async {
        await MainActor.run {
            mockWebSocketService.shouldSucceedConnection = true
            mockPriceGenerator.shouldSucceedGeneration = true
        }

        await viewModel.startTracking()

        XCTAssertTrue(viewModel.isTrackingActive)

        let connectCalled = await MainActor.run { mockWebSocketService.connectCalled }
        let startGeneratingCalled = await MainActor.run { mockPriceGenerator.startGeneratingCalled }

        XCTAssertTrue(connectCalled)
        XCTAssertTrue(startGeneratingCalled)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testStartTrackingFailure() async {
        await MainActor.run {
            mockWebSocketService.shouldSucceedConnection = false
            mockWebSocketService.connectionError = .connectionFailed("Test error")
        }

        await viewModel.startTracking()

        XCTAssertFalse(viewModel.isTrackingActive)
        XCTAssertNotNil(viewModel.errorMessage)

        let attemptRecoveryCalled = await MainActor.run { mockErrorRecovery.attemptRecoveryCalled }
        XCTAssertTrue(attemptRecoveryCalled)
    }

    func testSymbolsSortedByPrice() async {
        let prices = viewModel.symbols.map { $0.currentPrice }
        let sortedPrices = prices.sorted(by: >)
        XCTAssertEqual(prices, sortedPrices)
    }

    func testConstants() {
        XCTAssertEqual(Constants.PriceGeneration.updateInterval, 2.0)
        XCTAssertEqual(Constants.Network.maxRetryAttempts, 3)
        XCTAssertEqual(Constants.UI.minimumSymbolCount, 25)
    }
}

extension StockFeedViewModel {
    @MainActor
    static func createForTesting() -> StockFeedViewModel {
        return StockFeedViewModel(
            webSocketService: MockWebSocketService(),
            priceGeneratorService: MockPriceGeneratorService(),
            stockDataService: MockStockDataService(),
            errorRecoveryService: MockErrorRecoveryService(),
            logger: MockLogger()
        )
    }
}

extension SymbolDetailViewModel {
    @MainActor
    static func createForTesting(symbol: StockSymbol) -> SymbolDetailViewModel {
        return SymbolDetailViewModel(
            symbol: symbol,
            webSocketService: MockWebSocketService(),
            logger: MockLogger()
        )
    }
}
