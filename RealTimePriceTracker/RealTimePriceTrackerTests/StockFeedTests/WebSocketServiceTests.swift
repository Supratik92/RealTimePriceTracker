//
//  WebSocketServiceTests.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import XCTest
import Combine
@testable import RealTimePriceTracker

final class WebSocketServiceTests: XCTestCase {
    var webSocketService: WebSocketManager!
    var mockNetworkClient: MockNetworkClient!
    var mockLogger: MockLogger!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        mockNetworkClient = MockNetworkClient()
        webSocketService = WebSocketManager(networkClient: mockNetworkClient, logger: mockLogger)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables.removeAll()
        webSocketService = nil
        mockNetworkClient = nil
        mockLogger = nil
        super.tearDown()
    }

    func testConnectionDelegation() {
        let expectation = XCTestExpectation(description: "Connection delegated to network client")

        webSocketService.connect()
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(mockNetworkClient.connectCalled)
    }

    func testPriceUpdateDelegation() {
        let expectation = XCTestExpectation(description: "Price update delegated")
        let testUpdate = PriceUpdate(symbol: "TEST", price: 100.0, timestamp: "2025-08-23T10:30:00Z")

        webSocketService.sendPriceUpdate(testUpdate)
            .sink(
                receiveCompletion: { _ in expectation.fulfill() },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(mockNetworkClient.sendCalled)
        XCTAssertEqual(mockNetworkClient.lastSentData.count, 1)
    }

    func testPriceUpdatesStream() {
        let expectation = XCTestExpectation(description: "Price updates received")
        let testUpdate = PriceUpdate(symbol: "STREAM_TEST", price: 123.45, timestamp: "2025-08-23T10:30:00Z")

        webSocketService.priceUpdates
            .sink { update in
                if update.symbol == "STREAM_TEST" {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Simulate update from network client
        mockNetworkClient.simulateReceive(testUpdate)

        wait(for: [expectation], timeout: 1.0)
    }
}
