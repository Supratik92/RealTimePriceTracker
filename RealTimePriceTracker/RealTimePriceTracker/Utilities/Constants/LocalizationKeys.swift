//
//  LocalizableKeys.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

// MARK: - Localization Keys

struct LocalizationKeys {
    struct App {
        static let title = "app.title"
    }

    struct Connection {
        static let connected = "connection.status.connected"
        static let disconnected = "connection.status.disconnected"
        static let connecting = "connection.status.connecting"
        static let reconnecting = "connection.status.reconnecting"
        static let failed = "connection.status.failed"
    }

    struct Buttons {
        static let start = "button.start"
        static let stop = "button.stop"
        static let ok = "button.ok"
        static let dismiss = "button.dismiss"
        static let retry = "button.retry"
    }

    struct Errors {
        static let title = "error.title"

        struct Network {
            static let invalidURL = "error.network.invalid_url"
            static let connectionFailed = "error.network.connection_failed"
            static let sendFailed = "error.network.send_failed"
            static let receiveFailed = "error.network.receive_failed"
            static let encodingFailed = "error.network.encoding_failed"
            static let decodingFailed = "error.network.decoding_failed"
            static let timeout = "error.network.timeout"
            static let unavailable = "error.network.unavailable"
        }

        struct Stock {
            static let symbolNotFound = "error.stock.symbol_not_found"
            static let invalidPrice = "error.stock.invalid_price"
            static let updateFailed = "error.stock.update_failed"
        }

        struct Generator {
            static let alreadyGenerating = "error.generator.already_generating"
            static let generationFailed = "error.generator.generation_failed"
            static let websocketUnavailable = "error.generator.websocket_unavailable"
        }
    }

    struct Accessibility {
        static let loading = "accessibility.loading"
        static let errorBanner = "accessibility.error_banner"
        static let price = "accessibility.price"
        static let dollars = "accessibility.dollars"
        static let startTracking = "accessibility.start_tracking"
        static let stopTracking = "accessibility.stop_tracking"
        static let viewDetails = "accessibility.view_details"
        static let priceChange = "accessibility.price_change"
        static let currentPrice = "accessibility.current_price"
        static let priceMovement = "accessibility.price_movement"
        static let up = "accessibility.up"
        static let down = "accessibility.down"
        static let percent = "accessibility.percent"
    }

    struct Symbol {
        static let about = "symbol.about"
        static let details = "symbol.details"
        static let lastUpdated = "symbol.last_updated"
        static let previousPrice = "symbol.previous_price"
        static let priceChange = "symbol.price_change"
    }

    struct Theme {
        static let system = "theme.system"
        static let light = "theme.light"
        static let dark = "theme.dark"
    }
}
