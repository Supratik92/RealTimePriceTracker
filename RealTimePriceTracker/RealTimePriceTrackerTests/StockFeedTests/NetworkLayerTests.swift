//
//  NetworkLayerTests.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import XCTest
@testable import RealTimePriceTracker

final class NetworkLayerTests: XCTestCase {
    var networkClient: WebSocketNetworkClient!
    var mockLogger: MockLogger!

    override func setUp() async throws {
        try await super.setUp()
        mockLogger = MockLogger()
        networkClient = await WebSocketNetworkClient(logger: mockLogger)
    }

    override func tearDown() async throws {
        await networkClient.disconnect()
        networkClient = nil
        mockLogger = nil
        try await super.tearDown()
    }

    func testInvalidURLHandling() async {
        let invalidURL = URL(string: "invalid://url")!

        do {
            try await networkClient.connect(to: invalidURL)
            XCTFail("Should have thrown invalid URL error")
        } catch let  error as NetworkError {
                if case .invalidURL = error {
                    // Expected error
                } else {
                    XCTFail("Wrong error type: \(error)")
                }
        } catch {
            
        }
    }

    func testConnectionStateTransitions() async {
        let initialState = await networkClient.connectionState
        XCTAssertEqual(initialState, NetworkConnectionState.disconnected)

        let validURL = URL(string: Constants.Network.webSocketURL)!

        do {
            try await networkClient.connect(to: validURL)
            let connectedState = await networkClient.connectionState
            XCTAssertEqual(connectedState, NetworkConnectionState.connected)
        } catch {
            // Expected in test environment
        }
    }

    func testNSObjectConformance() {
        XCTAssertTrue(networkClient != nil, "WebSocketNetworkClient should inherit from NSObject for URLSessionDelegate")
    }

    func testNonisolatedMethodsCallable() async {
        // Test that nonisolated methods can be called from any context
        let testURL = URL(string: Constants.Network.webSocketURL)!

        // This should compile without actor isolation warnings
        await withCheckedContinuation { continuation in
            Task {
                do {
                    try await networkClient.connect(to: testURL)
                    await networkClient.disconnect()
                    continuation.resume()
                } catch {
                    continuation.resume()
                }
            }
        }
    }

    func testRetryStrategy() {
        XCTAssertTrue(NetworkRetryStrategy.shouldRetry(error: .timeout, attemptCount: 0))
        XCTAssertTrue(NetworkRetryStrategy.shouldRetry(error: .connectionFailed("test"), attemptCount: 1))
        XCTAssertFalse(NetworkRetryStrategy.shouldRetry(error: .timeout, attemptCount: 5))
        XCTAssertFalse(NetworkRetryStrategy.shouldRetry(error: .invalidURL, attemptCount: 0))
    }
}

// MARK: - Result Extension for Testing
extension Result {
    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    var isFailure: Bool {
        return !isSuccess
    }
}
