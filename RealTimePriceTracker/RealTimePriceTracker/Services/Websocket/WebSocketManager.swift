//
//  WebSocketManager.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation
import Combine

final class WebSocketManager: WebSocketService, ObservableObject {
    @Published var connectionError: NetworkError?

    private let networkClient: NetworkClient
    private let logger: any Logger
    private var cancellables = Set<AnyCancellable>()

    var isConnected: Bool {
        networkClient.isConnected
    }

    var connectionState: AnyPublisher<NetworkConnectionState, Never> {
        networkClient.connectionState
    }

    var priceUpdates: AnyPublisher<PriceUpdate, Never> {
        networkClient.receive(PriceUpdate.self)
            .catch { [weak self] error -> Empty<PriceUpdate, Never> in
                self?.logger.error("Price update receive failed", error: error, category: .websocket)
                return Empty()
            }
            .eraseToAnyPublisher()
    }

    init(networkClient: NetworkClient, logger: any Logger) {
        self.networkClient = networkClient
        self.logger = logger

        setupConnectionStateObserver()
    }

    private func setupConnectionStateObserver() {
        networkClient.connectionState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if case .failed(let error) = state {
                    self?.connectionError = error
                    self?.logger.error("Connection state failed", error: error, category: .websocket)
                } else {
                    self?.connectionError = nil
                }
            }
            .store(in: &cancellables)
    }

    func connect() -> AnyPublisher<Void, NetworkError> {
        guard let url = URL(string: Constants.Network.webSocketURL) else {
            logger.error("Invalid WebSocket URL", error: NetworkError.invalidURL, category: .websocket)
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        logger.info("Connecting to WebSocket", category: .websocket)

        return networkClient.connect(to: url)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.logger.error("WebSocket connection failed", error: error, category: .websocket)
                        self?.connectionError = error
                    } else {
                        self?.logger.info("WebSocket connected successfully", category: .websocket)
                        self?.connectionError = nil
                    }
                }
            )
            .eraseToAnyPublisher()
    }

    func disconnect() {
        logger.info("Disconnecting WebSocket", category: .websocket)
        networkClient.disconnect()
    }

    func sendPriceUpdate(_ update: PriceUpdate) -> AnyPublisher<Void, NetworkError> {
        logger.debug("Sending price update for \(update.symbol): $\(update.price.toCurrency())", category: .websocket)

        return networkClient.send(update)
            .receive(on: DispatchQueue.main)
            .handleEvents(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.logger.debug("Price update sent for \(update.symbol)", category: .websocket)
                    case .failure(let error):
                        self?.logger.error("Failed to send price update", error: error, category: .websocket)
                        self?.connectionError = error
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}
