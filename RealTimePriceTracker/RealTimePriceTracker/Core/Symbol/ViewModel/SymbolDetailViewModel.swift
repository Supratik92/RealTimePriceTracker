//
//  SymbolDetailViewModel.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Combine
import Foundation

@MainActor
final class SymbolDetailViewModel: ObservableObject {
    @Published var symbol: StockSymbol
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let webSocketService: any WebSocketService
    private let logger: any Logger
    private var priceStreamTask: Task<Void, Never>?

    init(symbol: StockSymbol, webSocketService: any WebSocketService, logger: any Logger) {
        self.symbol = symbol
        self.webSocketService = webSocketService
        self.logger = logger

        logger.info("Initialized detail view for symbol: \(symbol.symbol)", category: .ui)
        startPriceStream()
    }

    deinit {
        priceStreamTask?.cancel()
    }

    private func startPriceStream() {
        priceStreamTask = Task {
            do {
                let stream = webSocketService.startPriceUpdateStream()

                for try await update in stream {
                    if update.symbol == symbol.symbol {
                        await updatePrice(update)
                    }
                }
            } catch {
                logger.error("Price stream failed for \(symbol.symbol)", error: error, category: .ui)
                errorMessage = error.localizedDescription
            }
        }
    }

    private func updatePrice(_ update: PriceUpdate) async {
        let oldPrice = symbol.currentPrice
        symbol.previousPrice = oldPrice
        symbol.currentPrice = update.price
        symbol.lastUpdated = Date()

        logger.debug("Updated detail view price for \(symbol.symbol): \(oldPrice.toCurrency()) -> \(update.price.toCurrency())", category: .ui)

        if update.price != oldPrice {
            symbol.isFlashing = true

            Task {
                try? await Task.sleep(for: .seconds(Constants.PriceGeneration.flashAnimationDuration))
                symbol.isFlashing = false
            }
        }
    }
}
