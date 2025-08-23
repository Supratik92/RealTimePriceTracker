//
//  RandomPriceGenerator.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Combine
import Foundation


final class RandomPriceGenerator: PriceGeneratorService, ObservableObject {
    @Published private var _isGenerating = false

    var isGenerating: Bool { _isGenerating }

    private let webSocketService: any WebSocketService
    private let logger: any Logger
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init(webSocketService: any WebSocketService, logger: any Logger) {
        self.webSocketService = webSocketService
        self.logger = logger
    }

    deinit {
        stopGenerating()
    }

    func startGenerating(for symbols: [StockSymbol]) -> AnyPublisher<Void, PriceGeneratorError> {
        return Future<Void, PriceGeneratorError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.generationFailed("Service deallocated")))
                return
            }

            guard !self._isGenerating else {
                self.logger.warning("Price generation already active", category: .business)
                promise(.failure(.alreadyGenerating))
                return
            }

            guard self.webSocketService.isConnected else {
                self.logger.error("WebSocket not connected", error: PriceGeneratorError.webSocketNotAvailable, category: .business)
                promise(.failure(.webSocketNotAvailable))
                return
            }

            self.logger.info("Starting price generation for \(symbols.count) symbols", category: .business)
            self._isGenerating = true

            // Use Timer for simple periodic updates
            self.timer = Timer.scheduledTimer(withTimeInterval: Constants.PriceGeneration.updateInterval, repeats: true) { [weak self] _ in
                self?.generatePriceUpdates(for: symbols)
            }

            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }

    func stopGenerating() {
        logger.info("Stopping price generation", category: .business)
        timer?.invalidate()
        timer = nil
        _isGenerating = false
        cancellables.removeAll()
    }

    private func generatePriceUpdates(for symbols: [StockSymbol]) {
        symbols.forEach { symbol in
            let newPrice = PriceHelpers.generateRandomPriceChange(for: symbol.currentPrice)
            let update = PriceHelpers.createPriceUpdate(symbol: symbol.symbol, price: newPrice)

            webSocketService.sendPriceUpdate(update)
                .sink(
                    receiveCompletion: { [weak self] completion in
                        if case .failure(let error) = completion {
                            self?.logger.error("Failed to send price update for \(symbol.symbol)", error: error, category: .business)
                        }
                    },
                    receiveValue: { [weak self] _ in
                        self?.logger.debug("Price update sent for \(symbol.symbol)", category: .business)
                    }
                )
                .store(in: &cancellables)
        }
    }
}
