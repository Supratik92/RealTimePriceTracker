//
//  WebSocketManager.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

@MainActor
final class WebSocketManager: WebSocketService, ObservableObject {
    @Published var connectionError: NetworkError?

    private let networkClient: NetworkClient
    private let logger: any Logger
    private var priceUpdateTask: Task<Void, Never>?

    var isConnected: Bool {
        get async { await networkClient.isConnected }
    }

    var connectionState: NetworkConnectionState {
        get async { await networkClient.connectionState }
    }

    init(networkClient: NetworkClient, logger: any Logger) {
        self.networkClient = networkClient
        self.logger = logger
    }

    deinit {
        priceUpdateTask?.cancel()
    }

    nonisolated func connect() async throws {
        guard let url = URL(string: Constants.Network.webSocketURL) else {
            await MainActor.run {
                logger.error("Invalid WebSocket URL", error: nil, category: .websocket)
            }
            throw NetworkError.invalidURL
        }

        await MainActor.run {
            logger.info("Connecting to WebSocket", category: .websocket)
        }

        do {
            try await networkClient.connect(to: url)
            await MainActor.run {
                connectionError = nil
                logger.info("WebSocket connected successfully", category: .websocket)
            }
        } catch let error as NetworkError {
            await MainActor.run {
                logger.error("WebSocket connection failed", error: error, category: .websocket)
                connectionError = error
            }
            throw error
        }
    }

    nonisolated func disconnect() async {
        await MainActor.run {
            logger.info("Disconnecting WebSocket", category: .websocket)
            priceUpdateTask?.cancel()
            priceUpdateTask = nil
        }
        await networkClient.disconnect()
    }

    nonisolated func sendPriceUpdate(_ update: PriceUpdate) async throws {
        await MainActor.run {
            logger.debug("Sending price update for \(update.symbol): $\(update.price.toCurrency())", category: .websocket)
        }

        do {
            try await networkClient.send(update)
            await MainActor.run {
                logger.debug("Price update sent for \(update.symbol)", category: .websocket)
            }
        } catch let error as NetworkError {
            await MainActor.run {
                logger.error("Failed to send price update", error: error, category: .websocket)
                connectionError = error
            }
            throw error
        }
    }

    nonisolated func startPriceUpdateStream() -> AsyncThrowingStream<PriceUpdate, Error> {
        return AsyncThrowingStream<PriceUpdate, Error> { continuation in
            Task { @MainActor [weak self] in
                guard let self = self else {
                    continuation.finish(throwing: NetworkError.receiveFailed("Service deallocated"))
                    return
                }

                self.logger.info("Starting price update stream", category: .websocket)

                do {
                    let stream = self.networkClient.startReceiving(PriceUpdate.self)

                    // Forward the stream data
                    for try await update in stream {
                        continuation.yield(update)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}
