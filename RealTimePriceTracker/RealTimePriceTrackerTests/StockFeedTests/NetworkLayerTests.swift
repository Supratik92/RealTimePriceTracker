//
//  NetworkLayerTests.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import XCTest
import Combine
@testable import RealTimePriceTracker

final class NetworkLayerTests: XCTestCase {
    var networkClient: WebSocketNetworkClient!
    var mockLogger: MockLogger!
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        mockLogger = MockLogger()
        networkClient = WebSocketNetworkClient(logger: mockLogger)
    }

    override func tearDown() {
        networkClient.disconnect()
        cancellables.removeAll()
        networkClient = nil
        mockLogger = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertFalse(networkClient.isConnected)
    }

    func testInvalidURLHandling() {
        let expectation = XCTestExpectation(description: "Invalid URL error")
        let invalidURL = URL(string: "invalid://url")!

        networkClient.connect(to: invalidURL)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion,
                       case .invalidURL = error {
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testConnectionStatePublisher() {
        let expectation = XCTestExpectation(description: "Connection state changes")
        var stateChanges: [NetworkConnectionState] = []

        networkClient.connectionState
            .sink { state in
                stateChanges.append(state)
                if stateChanges.count >= 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // Attempt connection (will likely fail in test environment)
        let validURL = URL(string: Constants.Network.webSocketURL)!
        networkClient.connect(to: validURL)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(stateChanges.first, .disconnected)
        XCTAssertTrue(stateChanges.contains { if case .connecting = $0 { return true }; return false })
    }
}
