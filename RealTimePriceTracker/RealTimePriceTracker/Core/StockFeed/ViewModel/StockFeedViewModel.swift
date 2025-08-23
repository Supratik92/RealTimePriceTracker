//
//  StockFeedViewModel.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Combine

@MainActor
final class StockFeedViewModel: ObservableObject {
    @Published var symbols: [StockSymbol] = []
    @Published var isTrackingActive = false
    @Published var flashingSymbols: Set<String> = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let webSocketService: any WebSocketService
    private let priceGeneratorService: PriceGeneratorService
    private let stockDataService: StockDataService
    private let errorRecoveryService: ErrorRecoveryService
    private let logger: any Logger

    private var priceStreamTask: Task<Void, Never>?
    private var retryCount = 0

    init(
        webSocketService: any WebSocketService,
        priceGeneratorService: PriceGeneratorService,
        stockDataService: StockDataService,
        errorRecoveryService: ErrorRecoveryService,
        logger: any Logger
    ) {
        self.webSocketService = webSocketService
        self.priceGeneratorService = priceGeneratorService
        self.stockDataService = stockDataService
        self.errorRecoveryService = errorRecoveryService
        self.logger = logger

        Task {
            await setupInitialData()
        }
    }

    deinit {
        priceStreamTask?.cancel()
    }

    private func setupInitialData() async {
        logger.info("Setting up initial stock data", category: .ui)
        symbols = await stockDataService.getAllSymbols().sortedByPrice()
    }

    func startTracking() async {
        logger.info("Starting price tracking", category: .ui)
        isLoading = true
        errorMessage = nil
        retryCount = 0

        do {
            try await webSocketService.connect()
            try await priceGeneratorService.startGenerating(for: symbols)

            startPriceUpdateStream()
            isTrackingActive = true
            logger.info("Price tracking started successfully", category: .ui)

        } catch {
            logger.error("Failed to start tracking", error: error, category: .ui)
            errorMessage = error.localizedDescription

            if let networkError = error as? NetworkError,
               errorRecoveryService.shouldRetry(error: networkError, attemptCount: retryCount) {
                await attemptRecovery(from: networkError)
            }
        }

        isLoading = false
    }

    func stopTracking() async {
        logger.info("Stopping price tracking", category: .ui)
        priceStreamTask?.cancel()
        priceStreamTask = nil

        await priceGeneratorService.stopGenerating()
        await webSocketService.disconnect()

        isTrackingActive = false
    }

    func refreshData() async {
        logger.info("Refreshing stock data", category: .ui)
        symbols = await stockDataService.getAllSymbols().sortedByPrice()
    }

    private func startPriceUpdateStream() {
        priceStreamTask = Task {
            do {
                let stream = webSocketService.startPriceUpdateStream()

                for try await update in stream {
                    await updateSymbolPrice(update)
                }
            } catch {
                logger.error("Price update stream failed", error: error, category: .ui)
                errorMessage = error.localizedDescription
            }
        }
    }

    private func updateSymbolPrice(_ update: PriceUpdate) async {
        guard let index = symbols.firstIndex(where: { $0.symbol == update.symbol }) else {
            return
        }

        let currentSymbol = symbols[index]
        let result = await stockDataService.updateSymbolPrice(symbol: currentSymbol, newPrice: update.price)

        switch result {
        case .success(let updatedSymbol):
            symbols[index] = updatedSymbol
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    private func attemptRecovery(from error: NetworkError) async {
        retryCount += 1
        let delay = NetworkRetryStrategy.getRetryDelay(for: retryCount - 1)

        logger.info("Attempting recovery in \(delay) seconds (attempt \(retryCount))", category: .ui)

        do {
            try await errorRecoveryService.attemptRecovery(from: error, attemptCount: retryCount - 1)
            await startTracking()
        } catch {
            logger.error("Recovery attempt failed", error: error, category: .ui)
        }
    }
}
