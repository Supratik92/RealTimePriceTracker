//
//  WebSocketNetworkClient.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation
import Network
import Combine

final class WebSocketNetworkClient: NSObject, NetworkClient, ObservableObject {
    @Published private var _connectionState: NetworkConnectionState = .disconnected
    @Published private var _isConnected = false

    var isConnected: Bool { _isConnected }

    var connectionState: AnyPublisher<NetworkConnectionState, Never> {
        $_connectionState.eraseToAnyPublisher()
    }

    private var webSocketTask: URLSessionWebSocketTask?
    private var urlSession: URLSession?
    private let logger: any Logger
    private var networkMonitor: NWPathMonitor?
    private var isNetworkAvailable = true
    private var cancellables = Set<AnyCancellable>()
    private var connectionPromise: ((Result<Void, NetworkError>) -> Void)?

    private let receiveSubject = PassthroughSubject<Data, NetworkError>()

    init(logger: any Logger) {
        self.logger = logger
        super.init()
        setupNetworkMonitoring()
    }

    deinit {
        cleanup()
    }

    private func cleanup() {
        networkMonitor?.cancel()
        networkMonitor = nil
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        urlSession = nil
        cancellables.removeAll()
        connectionPromise = nil
    }

    private func setupNetworkMonitoring() {
        networkMonitor = NWPathMonitor()

        networkMonitor?.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                guard let self = self else { return }

                self.isNetworkAvailable = path.status == .satisfied
                if !self.isNetworkAvailable && self._connectionState == .connected {
                    self.logger.warning("Network became unavailable", category: .network)
                    self.handleDisconnection(error: .networkUnavailable)
                }
            }
        }

        networkMonitor?.start(queue: DispatchQueue.global(qos: .utility))
    }

    func connect(to url: URL) -> AnyPublisher<Void, NetworkError> {
        return Future<Void, NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.connectionFailed("Client deallocated")))
                return
            }

            self.logger.info("Connecting to: \(url.absoluteString)", category: .network)

            // Validate URL
            guard url.scheme == "wss" || url.scheme == "ws" else {
                self.logger.error("Invalid WebSocket URL scheme: \(url.scheme ?? "nil")",
                                  error: NetworkError.invalidURL,
                                  category: .network)
                promise(.failure(.invalidURL))
                return
            }

            // Check network
            guard self.isNetworkAvailable else {
                self.logger.error("Network unavailable",
                                  error: NetworkError.invalidURL,
                                  category: .network)
                promise(.failure(.networkUnavailable))
                return
            }

            // Set connecting state
            self._connectionState = .connecting

            // Store promise for later resolution
            self.connectionPromise = promise

            // Create URLSession and WebSocket task
            self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            self.webSocketTask = self.urlSession?.webSocketTask(with: url)
            self.webSocketTask?.resume()

            // Set up timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Network.connectionTimeout) {
                if self._connectionState == .connecting {
                    self.logger.error("Connection timeout", error: nil, category: .network)
                    self.connectionPromise?(.failure(.timeout))
                    self.connectionPromise = nil
                    self.handleDisconnection(error: .timeout)
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func disconnect() {
        logger.info("Disconnecting", category: .network)
        cleanup()
        _connectionState = .disconnected
        _isConnected = false
    }

    func send<T: Codable>(_ data: T) -> AnyPublisher<Void, NetworkError> {
        return Future<Void, NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.sendFailed("Client deallocated")))
                return
            }

            guard self._isConnected else {
                promise(.failure(.sendFailed("Not connected")))
                return
            }

            do {
                let jsonData = try JSONEncoder().encode(data)
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    logger.error("Cannot convert to string",
                                 error: NetworkError.decodingFailed("data"),
                                 category: .network)
                    return
                }
                self.webSocketTask?.send(.string(jsonString)) { error in
                    if let error = error {
                        self.logger.error("Send failed", error: error, category: .network)
                        promise(.failure(.sendFailed(error.localizedDescription)))
                    } else {
                        self.logger.debug("Message sent successfully", category: .network)
                        promise(.success(()))
                    }
                }
            } catch {
                self.logger.error("Encoding failed", error: error, category: .network)
                promise(.failure(.encodingFailed(error.localizedDescription)))
            }
        }
        .eraseToAnyPublisher()
    }

    func receive<T: Codable>(_ type: T.Type) -> AnyPublisher<T, NetworkError> {
        return receiveSubject
            .tryMap { data in
                try JSONDecoder().decode(type, from: data)
            }
            .mapError { error in
                NetworkError.decodingFailed(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    private func startListening() {
        guard _isConnected else { return }

        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                self.handleReceivedMessage(message)
                self.startListening() // Continue listening recursively
            case .failure(let error):
                self.logger.error("Receive failed", error: error, category: .network)
                self.receiveSubject.send(completion: .failure(.receiveFailed(error.localizedDescription)))
                self.handleDisconnection(error: .receiveFailed(error.localizedDescription))
            }
        }
    }

    private func handleReceivedMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let data):
            receiveSubject.send(data)
        case .string(let text):
            if let data = text.data(using: .utf8) {
                receiveSubject.send(data)
            } else {
                logger.warning("Failed to convert string message to data", category: .network)
            }
        @unknown default:
            logger.warning("Unknown message type received", category: .network)
        }
    }

    private func handleDisconnection(error: NetworkError) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            _connectionState = .failed(error)
            _isConnected = false
        }

        // Notify connection failure if promise is waiting
        connectionPromise?(.failure(error))
        connectionPromise = nil

        // Simple reconnection attempt
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Network.reconnectionDelay) {
            if case .failed = self._connectionState, self.isNetworkAvailable {
                self.logger.info("Attempting reconnection", category: .network)
                self._connectionState = .reconnecting
            }
        }
    }
}

// URLSessionWebSocketDelegate - Simple Implementation
extension WebSocketNetworkClient: URLSessionWebSocketDelegate {
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        logger.info("✅ WebSocket connection established", category: .network)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            _connectionState = .connected
            _isConnected = true
            // Notify connection success
            connectionPromise?(.success(()))
            connectionPromise = nil

            // Start receiving messages
            startListening()
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown"
        logger.info("❌ WebSocket closed - Code: \(closeCode.rawValue), Reason: \(reasonString)", category: .network)
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            _connectionState = .disconnected
            _isConnected = false

            // Notify connection failure if still connecting
            let error = NetworkError.connectionFailed("Connection closed: \(closeCode.rawValue)")
            connectionPromise?(.failure(error))
            connectionPromise = nil
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            logger.error("URLSession task completed with error", error: error, category: .network)
            let networkError = NetworkError.connectionFailed(error.localizedDescription)

            // Notify connection failure
            connectionPromise?(.failure(networkError))
            connectionPromise = nil

            handleDisconnection(error: networkError)
        }
    }
}
