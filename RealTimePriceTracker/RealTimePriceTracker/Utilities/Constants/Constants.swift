//
//  o.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

struct Constants {
    struct Network {
        static let webSocketURL = "wss://ws.postman-echo.com/raw"
        static let connectionTimeout: TimeInterval = 10.0
        static let reconnectionDelay: TimeInterval = 5.0
        static let maxRetryAttempts = 3
        static let retryDelays: [TimeInterval] = [1.0, 2.0, 5.0]
    }

    struct PriceGeneration {
        static let updateInterval: TimeInterval = 2.0
        static let priceVolatility: Double = 0.02 // 2%
        static let minimumPrice: Double = 1.0
        static let maximumPrice: Double = 10000.0
        static let flashAnimationDuration: TimeInterval = 1.0
    }

    struct UI {
        static let connectionIndicatorSize: CGFloat = 12.0
        static let buttonCornerRadius: CGFloat = 20.0
        static let cardCornerRadius: CGFloat = 16.0
        static let separatorHeight: CGFloat = 1.0
        static let progressViewScale: CGFloat = 1.2
        static let minimumSymbolCount = 25
        static let animationDuration: TimeInterval = 0.5
        static let minimumTapTarget: CGFloat = 44.0
    }

    struct DeepLink {
        static let scheme = "stocks"
        static let symbolPath = "symbol"
    }

    struct UserDefaults {
        static let selectedTheme = "selectedTheme"
    }

    struct App {
        static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.supratik.RealTimePriceTracker"
        static let logDateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
}
