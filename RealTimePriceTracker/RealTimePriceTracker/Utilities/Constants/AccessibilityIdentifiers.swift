//
//  AccessibilityIdentifiers.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

struct AccessibilityIdentifiers {
    struct StockFeed {
        static let navigationTitle = "stock_feed_navigation_title"
        static let stockList = "stock_feed_list"
        static let startButton = "stock_feed_start_button"
        static let stopButton = "stock_feed_stop_button"
        static let connectionStatus = "stock_feed_connection_status"
        static let errorBanner = "stock_feed_error_banner"
        static let dismissErrorButton = "stock_feed_dismiss_error_button"
        static let loadingIndicator = "stock_feed_loading_indicator"
        static let debugButton = "stock_feed_debug_button"
        static let deepLinkButton = "stock_feed_deeplink_button"
    }

    struct StockRow {
        static let cell = "stock_row_cell"
        static let symbolText = "stock_row_symbol"
        static let nameText = "stock_row_name"
        static let priceText = "stock_row_price"
        static let changeText = "stock_row_change"
    }

    struct ConnectionStatus {
        static let container = "connection_status_container"
        static let indicator = "connection_status_indicator"
        static let text = "connection_status_text"
    }

    struct SymbolDetail {
        static let navigationTitle = "symbol_detail_navigation_title"
        static let aboutSection = "symbol_detail_about"
        static let detailsSection = "symbol_detail_details"
    }
}
