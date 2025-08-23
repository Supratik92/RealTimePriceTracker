//
//  AppCoordinator.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var selectedSymbol: StockSymbol?

    private let logger: any Logger

    enum Destination: Hashable {
        case symbolDetail(StockSymbol)
    }

    init(logger: any Logger) {
        self.logger = logger
    }

    func navigate(to destination: Destination) async {
        switch destination {
        case .symbolDetail(let symbol):
            logger.info("Navigating to symbol detail: \(symbol.symbol)", category: .ui)
            selectedSymbol = symbol
            path.append(destination)
        }
    }

    func goBack() async {
        logger.info("Navigating back", category: .ui)
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func goToRoot() async {
        logger.info("Navigating to root", category: .ui)
        path.removeLast(path.count)
    }
}
