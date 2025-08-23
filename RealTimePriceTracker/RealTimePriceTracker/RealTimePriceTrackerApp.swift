//
//  RealTimePriceTrackerApp.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import SwiftUI

@main
struct RealTimePriceTrackerApp: App {
    @StateObject private var dependencyContainer = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environmentObject(dependencyContainer)
                .environmentObject(dependencyContainer.coordinator)
                .environmentObject(dependencyContainer.webSocketService)
                .environmentObject(dependencyContainer.themeManager)
                .environmentObject(dependencyContainer.logger)
                .preferredColorScheme(dependencyContainer.themeManager.colorScheme)
                .onOpenURL { url in
                    Task {
                        await dependencyContainer.deepLinkHandler.handle(url: url)
                    }
                }
        }
    }
}

