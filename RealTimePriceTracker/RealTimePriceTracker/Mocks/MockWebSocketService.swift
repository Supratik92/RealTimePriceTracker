//
//  MockWebSocketService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Combine
import Foundation

final class MockWebSocketService: WebSocketService, ObservableObject {
    @Published var connectionError: NetworkError?
    @Published private var _isConnected = false
    @Published private var _connectionState: NetworkConnectionState = .disconnected

    var isConnected: Bool { _isConnected }

    var connectionState: AnyPublisher<NetworkConnectionState, Never> {
        $_connectionState.eraseToAnyPublisher()
    }

    private let priceUpdateSubject = PassthroughSubject<PriceUpdate, Never>()
    var priceUpdates: AnyPublisher<PriceUpdate, Never> {
        priceUpdateSubject.eraseToAnyPublisher()
    }

    var connectCalled = false
    var disconnectCalled = false
    var shouldSucceedConnection = true
    var sentUpdates: [PriceUpdate] = []

    func connect() -> AnyPublisher<Void, NetworkError> {
        return Future<Void, NetworkError> { promise in
            self.connectCalled = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.shouldSucceedConnection {
                    self._isConnected = true
                    self._connectionState = .connected
                    promise(.success(()))
                } else {
                    let error = self.connectionError ?? NetworkError.connectionFailed("Mock connection failed")
                    self._connectionState = .failed(error)
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func disconnect() {
        disconnectCalled = true
        _isConnected = false
        _connectionState = .disconnected
    }

    func sendPriceUpdate(_ update: PriceUpdate) -> AnyPublisher<Void, NetworkError> {
        return Future<Void, NetworkError> { promise in
            guard self._isConnected else {
                promise(.failure(.sendFailed("Not connected")))
                return
            }

            self.sentUpdates.append(update)
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    func simulateUpdate(_ update: PriceUpdate) {
        priceUpdateSubject.send(update)
    }
}

extension MockWebSocketService {
    func simulateConnectionError() {
        DispatchQueue.main.async {
            self.connectionError = self.connectionError ?? .connectionFailed("Simulated error")
        }
    }

    func simulateReconnection() {
        _connectionState = .reconnecting

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if self.shouldSucceedConnection {
                self._isConnected = true
                self._connectionState = .connected
            }
        }
    }

    func reset() {
        connectCalled = false
        disconnectCalled = false
        shouldSucceedConnection = true
        sentUpdates.removeAll()
        connectionError = nil
        _isConnected = false
        _connectionState = .disconnected
    }
}
