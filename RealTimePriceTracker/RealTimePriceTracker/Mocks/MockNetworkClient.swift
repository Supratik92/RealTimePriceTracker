//
//  MockNetworkClient.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Foundation
import Combine

final class MockNetworkClient: NetworkClient {
    @Published private var _connectionState: NetworkConnectionState = .disconnected
    @Published private var _isConnected = false

    var isConnected: Bool { _isConnected }
    var connectionState: AnyPublisher<NetworkConnectionState, Never> {
        $_connectionState.eraseToAnyPublisher()
    }

    var connectCalled = false
    var disconnectCalled = false
    var sendCalled = false
    var shouldSucceedConnection = true
    var shouldSucceedSend = true
    var lastSentData: [Data] = []

    private let receiveSubject = PassthroughSubject<Data, NetworkError>()

    func connect(to url: URL) -> AnyPublisher<Void, NetworkError> {
        connectCalled = true

        return Future<Void, NetworkError> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.shouldSucceedConnection {
                    self._isConnected = true
                    self._connectionState = .connected
                    promise(.success(()))
                } else {
                    self._connectionState = .failed(.connectionFailed("Mock connection failed"))
                    promise(.failure(.connectionFailed("Mock connection failed")))
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

    func send<T: Codable>(_ data: T) -> AnyPublisher<Void, NetworkError> {
        sendCalled = true

        return Future<Void, NetworkError> { promise in
            if self.shouldSucceedSend {
                do {
                    let jsonData = try JSONEncoder().encode(data)
                    self.lastSentData.append(jsonData)
                    promise(.success(()))
                } catch {
                    promise(.failure(.encodingFailed(error.localizedDescription)))
                }
            } else {
                promise(.failure(.sendFailed("Mock send failed")))
            }
        }
        .eraseToAnyPublisher()
    }

    func receive<T: Codable>(_ type: T.Type) -> AnyPublisher<T, NetworkError> {
        return receiveSubject
            .tryMap { data in
                try JSONDecoder().decode(type, from: data)
            }
            .mapError { NetworkError.decodingFailed($0.localizedDescription) }
            .eraseToAnyPublisher()
    }

    func simulateReceive<T: Codable>(_ object: T) {
        do {
            let data = try JSONEncoder().encode(object)
            receiveSubject.send(data)
        } catch {
            receiveSubject.send(completion: .failure(.encodingFailed(error.localizedDescription)))
        }
    }
}
