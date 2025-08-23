//
//  DeepLinkHandler.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Foundation
import Combine

protocol DeepLinkHandler: AnyObject {
    func handle(url: URL) async
}

final class StockDeepLinkHandler: DeepLinkHandler {
    private let coordinator: AppCoordinator
    private let stockDataService: StockDataService
    private let logger: any Logger
    private var cancellables = Set<AnyCancellable>()

    init(coordinator: AppCoordinator, stockDataService: StockDataService, logger: any Logger) {
        self.coordinator = coordinator
        self.stockDataService = stockDataService
        self.logger = logger
    }

    func handle(url: URL) {
        logger.info("Handling deep link: \(url.absoluteString)", category: .deeplink)

        guard url.scheme == Constants.DeepLink.scheme else {
            logger.warning("Invalid deep link scheme: \(url.scheme ?? "nil")", category: .deeplink)
            return
        }

        let pathComponents = URLHelpers.extractPathComponents(from: url)

        guard pathComponents.count >= 1,
        let symbolCode = pathComponents.first else {
            logger.warning("Invalid deep link path: \(url.path)", category: .deeplink)
            return
        }

        stockDataService.getSymbol(by: symbolCode)
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] symbol in
                    self?.logger.info("Navigating to symbol via deep link: \(symbolCode)", category: .deeplink)
                    Task {
                        await self?.coordinator.navigate(to: .symbolDetail(symbol))
                    }
                }
            )
            .store(in: &cancellables)
    }
}
