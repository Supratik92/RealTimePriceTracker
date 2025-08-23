//
//  AppCoordinatorView.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import SwiftUI

struct AppCoordinatorView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var dependencyContainer: DependencyContainer

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            StockFeedView(viewModel: dependencyContainer.makeStockFeedViewModel())
                .navigationDestination(for: AppCoordinator.Destination.self) { destination in
                    switch destination {
                    case .symbolDetail(let symbol):
                        SymbolDetailView(viewModel: dependencyContainer.makeSymbolDetailViewModel(symbol: symbol))
                    }
                }
        }
    }
}
