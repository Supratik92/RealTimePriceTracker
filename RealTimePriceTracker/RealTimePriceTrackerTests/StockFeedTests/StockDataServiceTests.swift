//
//  StockDataServiceTests.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import XCTest
import Combine
@testable import RealTimePriceTracker

final class StockDataServiceTests: XCTestCase {
    var stockDataService: LocalStockDataService!
    var mockLogger: MockLogger!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        stockDataService = LocalStockDataService(logger: mockLogger)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables.removeAll()
        stockDataService = nil
        mockLogger = nil
        super.tearDown()
    }

    func testGetAllSymbols() {
        let expectation = XCTestExpectation(description: "Symbols loaded")

        stockDataService.getAllSymbols()
            .sink { symbols in
                XCTAssertEqual(symbols.count, Constants.UI.minimumSymbolCount)
                XCTAssertTrue(symbols.allSatisfy { !$0.symbol.isEmpty })
                XCTAssertTrue(symbols.allSatisfy { !$0.name.isEmpty })
                XCTAssertTrue(symbols.allSatisfy { $0.currentPrice > 0 })
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testGetSymbolByCode() {
        let expectation = XCTestExpectation(description: "Symbol found")

        stockDataService.getSymbol(by: "AAPL")
            .sink { aaplSymbol in
                XCTAssertNotNil(aaplSymbol)
                XCTAssertEqual(aaplSymbol?.symbol, "AAPL")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testUpdateSymbolPriceValid() {
        let symbol = StockSymbol.sampleSymbols.first!
        let newPrice = 200.0

        let result = stockDataService.updateSymbolPrice(symbol: symbol, newPrice: newPrice)

        switch result {
        case .success(let updatedSymbol):
            XCTAssertEqual(updatedSymbol.currentPrice, newPrice)
            XCTAssertEqual(updatedSymbol.previousPrice, symbol.currentPrice)
            XCTAssertEqual(updatedSymbol.symbol, symbol.symbol)
        case .failure:
            XCTFail("Valid price update should succeed")
        }
    }

    func testUpdateSymbolPriceInvalid() {
        let symbol = StockSymbol.sampleSymbols.first!
        let invalidPrice = -10.0

        let result = stockDataService.updateSymbolPrice(symbol: symbol, newPrice: invalidPrice)

        switch result {
        case .success:
            XCTFail("Invalid price update should fail")
        case .failure(let error):
            if case .invalidPrice(let price) = error {
                XCTAssertEqual(price, invalidPrice)
            } else {
                XCTFail("Should fail with invalidPrice error")
            }
        }
    }
}
