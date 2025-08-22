//
//  LogCategory.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import OSLog

enum LogCategory: String, CaseIterable {
    case network = "Network"
    case websocket = "WebSocket"
    case ui = "UI"
    case business = "Business"
    case deeplink = "DeepLink"
    case accessibility = "Accessibility"

    var osLog: OSLog {
        OSLog(subsystem: "Constants.App.bundleIdentifier", category: rawValue)
    }
}
