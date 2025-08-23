//
//  MockWebSocketService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Combine

@MainActor
final class MockWebSocketService: WebSocketService, ObservableObject {
    @Published var connectionError: NetworkError?

    private var _isConnected = false
    private var _connectionState: NetworkConnectionState = .disconnected

    var isConnected: Bool {
        get async { _isConnected }
    }

    var connectionState: NetworkConnectionState {
        get async { _connectionState }
    }

    var connectCalled = false
    var disconnectCalled = false
    var shouldSucceedConnection = true
    var sentUpdates: [PriceUpdate] = []

    nonisolated func connect() async throws {
        try await MainActor.run {
            connectCalled = true

            if shouldSucceedConnection {
                _isConnected = true
                _connectionState = .connected
            } else {
                let error = connectionError ?? NetworkError.connectionFailed("Mock connection failed")
                throw error
            }
        }
    }

    nonisolated func disconnect() async {
        await MainActor.run {
            disconnectCalled = true
            _isConnected = false
            _connectionState = .disconnected
        }
    }

    nonisolated func sendPriceUpdate(_ update: PriceUpdate) async throws {
        let connected = await isConnected
        guard connected else {
            throw NetworkError.sendFailed("Not connected")
        }

        await MainActor.run {
            sentUpdates.append(update)
        }
    }

    nonisolated func startPriceUpdateStream() -> AsyncThrowingStream<PriceUpdate, Error> {
        return AsyncThrowingStream<PriceUpdate, Error> { continuation in
            Task { [weak self] in
                guard let self = self else {
                    continuation.finish(throwing: NetworkError.receiveFailed("Service deallocated"))
                    return
                }

                let updates = await MainActor.run { self.sentUpdates }

                for update in updates {
                    continuation.yield(update)
                    try? await Task.sleep(for: .milliseconds(100))
                }
                continuation.finish()
            }
        }
    }
}
