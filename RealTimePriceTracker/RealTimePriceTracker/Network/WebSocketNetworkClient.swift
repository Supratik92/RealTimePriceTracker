//
//  WebSocketNetworkClient.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation
import Network

@MainActor
final class WebSocketNetworkClient: NSObject, NetworkClient, ObservableObject {
    @Published private var currentConnectionState: NetworkConnectionState = .disconnected
    @Published private var isConnectionEstablished = false

    var isConnected: Bool {
        get async { isConnectionEstablished }
    }

    var connectionState: NetworkConnectionState {
        get async { currentConnectionState }
    }

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private let logger: ConsoleLogger
    private let networkMonitor = NWPathMonitor()
    private var isNetworkAvailable = true

    init(logger: ConsoleLogger) {
        self.logger = logger
        super.init()
        setupNetworkMonitoring()
    }

    deinit {
        networkMonitor.cancel()
    }

    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            Task { @MainActor in
                self.isNetworkAvailable = path.status == .satisfied
                if !self.isNetworkAvailable && self.currentConnectionState == .connected {
                    self.logger.warning("Network became unavailable", category: .network)
                    await self.handleDisconnection(error: .networkUnavailable)
                }
            }
        }
        networkMonitor.start(queue: DispatchQueue.global(qos: .utility))
    }

    func connect(to url: URL) async throws {
        logger.info("Connecting to: \(url.absoluteString)", category: .network)

        guard url.scheme == "ws" || url.scheme == "wss" else {
            logger.error("Invalid WebSocket URL scheme", category: .network)
            throw NetworkError.invalidURL
        }

        guard isNetworkAvailable else {
            logger.error("Network unavailable", category: .network)
            throw NetworkError.networkUnavailable
        }

        currentConnectionState = .connecting

        urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = urlSession?.webSocketTask(with: url)
        webSocketTask?.resume()

        try await waitForConnection()
    }

    private func waitForConnection() async throws {
        let timeoutTask = Task {
            try await Task.sleep(for: .seconds(Constants.Network.connectionTimeout))
            throw NetworkError.timeout
        }

        let connectionTask = Task {
            while currentConnectionState == .connecting {
                try await Task.sleep(for: .milliseconds(100))
            }

            if currentConnectionState != .connected {
                throw NetworkError.connectionFailed("Failed to establish connection")
            }
        }

        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask { try await timeoutTask.value }
                group.addTask { try await connectionTask.value }

                try await group.next()
                group.cancelAll()
            }
        } catch {
            let networkError = error as? NetworkError ?? .connectionFailed(error.localizedDescription)
            await handleDisconnection(error: networkError)
            throw error
        }
    }

    func disconnect() async {
        logger.info("Disconnecting", category: .network)
        cleanup()
        currentConnectionState = .disconnected
        isConnectionEstablished = false
    }

    func send<T: Codable>(_ data: T) async throws {
        guard isConnectionEstablished else {
            throw NetworkError.sendFailed("Not connected")
        }

        do {
            let jsonData = try JSONEncoder().encode(data)
            let message = URLSessionWebSocketTask.Message.data(jsonData)

            try await webSocketTask?.send(message)
            logger.debug("Message sent successfully", category: .network)
        } catch {
            logger.error("Send failed", error: error, category: .network)
            throw NetworkError.sendFailed(error.localizedDescription)
        }
    }

    nonisolated func startReceiving<T: Codable>(_ type: T.Type) -> AsyncThrowingStream<T, Error> {
        return AsyncThrowingStream<T, Error> { continuation in
            Task { [weak self] in
                guard let self = self else {
                    continuation.finish(throwing: NetworkError.receiveFailed("Client deallocated"))
                    return
                }

                while await self.isConnectionEstablished {
                    do {
                        let message = try await self.webSocketTask?.receive()
                        if let data = await self.extractData(from: message) {
                            let decodedMessage = try JSONDecoder().decode(type, from: data)
                            continuation.yield(decodedMessage)
                        }
                    } catch {
                        await MainActor.run { [weak self] in
                            self?.logger.error("Receive failed", error: error, category: .network)
                        }
                        continuation.finish(throwing: NetworkError.receiveFailed(error.localizedDescription))
                        break
                    }
                }
                continuation.finish()
            }
        }
    }

    private func extractData(from message: URLSessionWebSocketTask.Message?) -> Data? {
        guard let message = message else { return nil }

        switch message {
        case .data(let data):
            return data
        case .string(let text):
            return text.data(using: .utf8)
        @unknown default:
            logger.warning("Unknown message type received", category: .network)
            return nil
        }
    }

    private func handleDisconnection(error: NetworkError) async {
        currentConnectionState = .failed(error)
        isConnectionEstablished = false

        // Schedule reconnection attempt
        Task { [weak self] in
            try? await Task.sleep(for: .seconds(Constants.Network.reconnectionDelay))

            await MainActor.run { [weak self] in
                guard let self = self else { return }

                if case .failed = self.currentConnectionState, self.isNetworkAvailable {
                    self.logger.info("Attempting reconnection", category: .network)
                    self.currentConnectionState = .reconnecting
                }
            }
        }
    }

    private func cleanup() {
        networkMonitor.cancel()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        urlSession = nil
    }
}

extension WebSocketNetworkClient: URLSessionWebSocketDelegate {
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        Task { @MainActor in
            logger.info("WebSocket connection established", category: .network)
            currentConnectionState = .connected
            isConnectionEstablished = true
        }
    }

    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        Task { @MainActor in
            let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown"
            logger.info("Connection closed - Code: \(closeCode.rawValue), Reason: \(reasonString)", category: .network)
            currentConnectionState = .disconnected
            isConnectionEstablished = false
        }
    }
}
