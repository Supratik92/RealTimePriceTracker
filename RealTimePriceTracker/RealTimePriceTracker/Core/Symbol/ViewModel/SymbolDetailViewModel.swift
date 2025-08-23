//
//  SymbolDetailViewModel.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Combine
import Foundation

final class SymbolDetailViewModel: ObservableObject {
    @Published var symbol: StockSymbol
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var connectionError: NetworkError?

    private let webSocketService: any WebSocketService
    private let logger: any Logger
    private var cancellables = Set<AnyCancellable>()

    init(symbol: StockSymbol,
         webSocketService: any WebSocketService,
         logger: any Logger) {
        self.symbol = symbol
        self.webSocketService = webSocketService
        self.connectionError = webSocketService.connectionError
        self.logger = logger

        logger.info("Initialized detail view for symbol: \(symbol.symbol)", category: .ui)
        setupPriceUpdates()
        setupErrorHandling()
    }

    private func setupPriceUpdates() {
        webSocketService.priceUpdates
            .filter { [weak self] update in
                update.symbol == self?.symbol.symbol
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                self?.updatePrice(update)
            }
            .store(in: &cancellables)
    }

    private func setupErrorHandling() {
        $connectionError
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.errorMessage = error.localizedDescription
            }
            .store(in: &cancellables)
    }

    private func updatePrice(_ update: PriceUpdate) {
        let oldPrice = symbol.currentPrice
        symbol.previousPrice = oldPrice
        symbol.currentPrice = update.price
        symbol.lastUpdated = Date()

        logger.debug("Updated detail view price for \(symbol.symbol): \(oldPrice.toCurrency()) -> \(update.price.toCurrency())", category: .ui)

        if update.price != oldPrice {
            symbol.isFlashing = true

            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.PriceGeneration.flashAnimationDuration) {
                self.symbol.isFlashing = false
            }
        }
    }
}
