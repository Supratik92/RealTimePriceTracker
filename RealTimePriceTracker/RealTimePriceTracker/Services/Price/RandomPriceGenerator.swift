//
//  RandomPriceGenerator.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import SwiftUI

@MainActor
final class RandomPriceGenerator: PriceGeneratorService, ObservableObject {
    @Published private var _isGenerating = false

    var isGenerating: Bool {
        get async { _isGenerating }
    }

    private let webSocketService: any WebSocketService
    private let logger: any Logger
    private var generationTask: Task<Void, Never>?

    init(webSocketService: any WebSocketService, logger: any Logger) {
        self.webSocketService = webSocketService
        self.logger = logger
    }

    deinit {
        generationTask?.cancel()
    }

    func startGenerating(for symbols: [StockSymbol]) async throws {
        guard !_isGenerating else {
            logger.warning("Price generation already active", category: .business)
            throw PriceGeneratorError.alreadyGenerating
        }

        guard await webSocketService.isConnected else {
            logger.error("WebSocket not connected", error: PriceGeneratorError.webSocketNotAvailable, category: .business)
            throw PriceGeneratorError.webSocketNotAvailable
        }

        logger.info("Starting price generation for \(symbols.count) symbols", category: .business)
        _isGenerating = true

        generationTask = Task {
            while !Task.isCancelled && _isGenerating {
                await generatePriceUpdates(for: symbols)

                do {
                    try await Task.sleep(for: .seconds(Constants.PriceGeneration.updateInterval))
                } catch {
                    break
                }
            }
        }
    }

    func stopGenerating() async {
        logger.info("Stopping price generation", category: .business)
        generationTask?.cancel()
        generationTask = nil
        _isGenerating = false
    }

    private func generatePriceUpdates(for symbols: [StockSymbol]) async {
        await withTaskGroup(of: Void.self) { group in
            for symbol in symbols {
                group.addTask { [weak self] in
                    guard let self = self else { return }

                    let newPrice = PriceHelpers.generateRandomPriceChange(for: symbol.currentPrice)
                    let update = PriceHelpers.createPriceUpdate(symbol: symbol.symbol, price: newPrice)

                    do {
                        try await self.webSocketService.sendPriceUpdate(update)
                        await MainActor.run {
                            self.logger.debug("Price update sent for \(symbol.symbol)", category: .business)
                        }
                    } catch {
                        await MainActor.run {
                            self.logger.error("Failed to send price update for \(symbol.symbol)", error: error, category: .business)
                        }
                    }
                }
            }
        }
    }
}
