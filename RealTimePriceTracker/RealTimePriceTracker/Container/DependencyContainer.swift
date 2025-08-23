//
//  DependencyContainer.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation
import Combine

@MainActor
final class DependencyContainer: ObservableObject {
    // MARK: - Core Services
    lazy var logger: some Logger = ConsoleLogger()
    lazy var networkClient: NetworkClient = WebSocketNetworkClient(logger: logger)
    lazy var webSocketService: some WebSocketService = WebSocketManager(
        networkClient: networkClient,
        logger: logger
    )

    // MARK: - Business Services
    lazy var priceGeneratorService: PriceGeneratorService = RandomPriceGenerator(
        webSocketService: webSocketService,
        logger: logger
    )
    lazy var stockDataService: StockDataService = LocalStockDataService(logger: logger)
    lazy var errorRecoveryService: ErrorRecoveryService = NetworkErrorRecovery(logger: logger)

    // MARK: - UI Services
    lazy var themeManager: ThemeManager = ThemeManager()
    lazy var coordinator: AppCoordinator = AppCoordinator(logger: logger)
    lazy var deepLinkHandler: DeepLinkHandler = StockDeepLinkHandler(
        coordinator: coordinator,
        stockDataService: stockDataService,
        logger: logger
    )

    // MARK: - ViewModels Factory
    func makeStockFeedViewModel() -> StockFeedViewModel {
        StockFeedViewModel(
            webSocketService: webSocketService,
            priceGeneratorService: priceGeneratorService,
            stockDataService: stockDataService,
            errorRecoveryService: errorRecoveryService,
            logger: logger
        )
    }

    func makeSymbolDetailViewModel(symbol: StockSymbol) -> SymbolDetailViewModel {
        SymbolDetailViewModel(
            symbol: symbol,
            webSocketService: webSocketService,
            logger: logger
        )
    }
}
