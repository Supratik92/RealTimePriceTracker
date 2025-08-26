//
//  StockFeedViewModel.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Combine
import Foundation

final class StockFeedViewModel: ObservableObject {
    @Published var symbols: [StockSymbol] = []
    @Published var isTrackingActive = false
    @Published var flashingSymbols: Set<String> = []
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var connectionError: NetworkError?

    private let webSocketService: any WebSocketService
    private let priceGeneratorService: PriceGeneratorService
    private let stockDataService: StockDataService
    private let errorRecoveryService: ErrorRecoveryService
    private let logger: any Logger

    private var cancellables = Set<AnyCancellable>()
    private var retryCount = 0
    private var currentNetworkState: NetworkConnectionState?

    init(
        webSocketService: any WebSocketService,
        priceGeneratorService: PriceGeneratorService,
        stockDataService: StockDataService,
        errorRecoveryService: ErrorRecoveryService,
        logger: any Logger
    ) {
        self.webSocketService = webSocketService
        self.connectionError = webSocketService.connectionError
        self.priceGeneratorService = priceGeneratorService
        self.stockDataService = stockDataService
        self.errorRecoveryService = errorRecoveryService
        self.logger = logger

        listenToConnectionState()
        setupInitialData()
        setupPriceUpdates()
        setupErrorHandling()
    }

    private func setupInitialData() {
        stockDataService.getAllSymbols()
            .map { $0.sortedByPrice() }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] symbols in
                self?.symbols = symbols
                self?.logger.info("Loaded \(symbols.count) stock symbols", category: .ui)
            }
            .store(in: &cancellables)
    }

    private func listenToConnectionState() {
        webSocketService.connectionState.sink { [weak self] currentState in
            self?.currentNetworkState = currentState
        }.store(in: &cancellables)
    }

    private func setupPriceUpdates() {
        logger.debug("🔄 Setting up price update subscription", category: .ui)

        webSocketService.priceUpdates
            .handleEvents(
                receiveSubscription: { [weak self] _ in
                    self?.logger.debug("📡 Subscribed to price updates stream", category: .ui)
                },
                receiveOutput: { [weak self] update in
                    self?.logger.debug("📥 ViewModel received price update: \(update.symbol) = $\(update.price.toCurrency())", category: .ui)
                },
                receiveCompletion: { [weak self] completion in
                    self?.logger.info("Price updates stream completed", category: .ui)
                }
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                self?.updateSymbolPrice(update)
            }
            .store(in: &cancellables)
    }

    private func setupErrorHandling() {
        $connectionError
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.errorMessage = error.localizedDescription
                self?.logger.error("WebSocket error occurred", error: error, category: .ui)
            }
            .store(in: &cancellables)
    }

    func startTracking() {
        logger.info("Starting price tracking", category: .ui)
        isLoading = true
        errorMessage = nil
        retryCount = 0

        guard let currentState = self.currentNetworkState,
              (currentState != .connecting || currentState != .reconnecting) else {
            logger.info("Current network connection is already is in progress", category: .network)
            return
        }

        webSocketService.connect()
            .receive(on: DispatchQueue.main)
            .mapError { $0 as Error }
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: PriceGeneratorError.generationFailed("ViewModel deallocated"))
                        .eraseToAnyPublisher()
                }
                return self.priceGeneratorService.startGenerating(for: self.symbols)
                    .mapError { $0 as Error }
                    .eraseToAnyPublisher()
            }
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.logger.error("Failed to start tracking", error: error, category: .ui)

                        // Simple retry attempt
                        if let networkError = error as? NetworkError,
                           self?.errorRecoveryService.shouldRetry(error: networkError, attemptCount: self?.retryCount ?? 0) == true {
                            self?.attemptRecovery(from: networkError)
                        }
                    } else {
                        self?.isTrackingActive = true
                        self?.logger.info("Price tracking started successfully", category: .ui)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    func stopTracking() {
        logger.info("Stopping price tracking", category: .ui)
        priceGeneratorService.stopGenerating()
        webSocketService.disconnect()
        isTrackingActive = false
        cancellables.removeAll()
        setupInitialData() // Re-setup basic subscriptions
        setupPriceUpdates()
        setupErrorHandling()
    }

    func refreshData() {
        logger.info("Refreshing stock data", category: .ui)
        stockDataService.getAllSymbols()
            .map { $0.sortedByPrice() }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] symbols in
                self?.symbols = symbols
            }
            .store(in: &cancellables)
    }

    private func updateSymbolPrice(_ update: PriceUpdate) {
        guard let index = symbols.firstIndex(where: { $0.symbol == update.symbol }) else {
            logger.warning("Received update for unknown symbol: \(update.symbol)", category: .ui)
            return
        }

        let currentSymbol = symbols[index]
        let result = stockDataService.updateSymbolPrice(symbol: currentSymbol, newPrice: update.price)

        switch result {
        case .success(let updatedSymbol):
            logger.debug("Successfully updated price for \(update.symbol)", category: .ui)

            // Update the symbol in the array
            symbols[index] = updatedSymbol

            // Trigger flash animation
            symbols[index].isFlashing = true
            flashingSymbols.insert(update.symbol)

            // Stop flashing after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.PriceGeneration.flashAnimationDuration) {
                self.symbols[index].isFlashing = false
                self.flashingSymbols.remove(update.symbol)
            }

            symbols = symbols.sortedByPrice()

        case .failure(let error):
            logger.error("Failed to update symbol price", error: error, category: .ui)
            errorMessage = error.localizedDescription
        }
    }

    private func attemptRecovery(from error: NetworkError) {
        retryCount += 1
        let delay = errorRecoveryService.getRetryDelay(for: retryCount - 1)

        logger.info("Attempting recovery in \(delay) seconds (attempt \(retryCount))", category: .ui)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.startTracking()
        }
    }
}
