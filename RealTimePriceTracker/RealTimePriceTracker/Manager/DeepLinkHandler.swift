//
//  DeepLinkHandler.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Foundation

protocol DeepLinkHandler: AnyObject {
    func handle(url: URL) async
}

final class StockDeepLinkHandler: DeepLinkHandler {
    private let coordinator: AppCoordinator
    private let stockDataService: StockDataService
    private let logger: any Logger

    init(coordinator: AppCoordinator, stockDataService: StockDataService, logger: any Logger) {
        self.coordinator = coordinator
        self.stockDataService = stockDataService
        self.logger = logger
    }

    func handle(url: URL) async {
        logger.info("Handling deep link: \(url.absoluteString)", category: .deeplink)

        guard url.scheme == Constants.DeepLink.scheme else {
            logger.warning("Invalid deep link scheme: \(url.scheme ?? "nil")", category: .deeplink)
            return
        }

        let pathComponents = URLHelpers.extractPathComponents(from: url)

        guard pathComponents.count >= 2,
              pathComponents[0] == Constants.DeepLink.symbolPath else {
            logger.warning("Invalid deep link path: \(url.path)", category: .deeplink)
            return
        }

        let symbolCode = pathComponents[1].uppercased()

        guard let symbol = await stockDataService.getSymbol(by: symbolCode) else {
            logger.error("Symbol not found for deep link: \(symbolCode)", error: nil, category: .deeplink)
            return
        }

        logger.info("Navigating to symbol via deep link: \(symbolCode)", category: .deeplink)
        await coordinator.navigate(to: .symbolDetail(symbol))
    }
}
