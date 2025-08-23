//
//  StockSymbol.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation
import SwiftUI

struct StockSymbol: Identifiable, Codable, Hashable {
    let symbol: String
    let name: String
    let description: String
    var currentPrice: Double
    var previousPrice: Double
    var lastUpdated: Date
    var isFlashing: Bool = false
    var id = UUID()

    var priceChange: Double {
        currentPrice - previousPrice
    }

    var priceChangePercentage: Double {
        guard previousPrice > 0 else { return 0 }
        return (priceChange / previousPrice) * 100
    }

    var priceDirection: PriceDirection {
        if currentPrice > previousPrice {
            return .up
        } else if currentPrice < previousPrice {
            return .down
        } else {
            return .neutral
        }
    }

    var priceChangeAccessibilityLabel: String {
        return LocalizationKeys.Accessibility.priceChange.localized() +
               " \(priceChange >= 0 ? LocalizationKeys.Accessibility.up.localized() : LocalizationKeys.Accessibility.down.localized()) " +
               "\(abs(priceChange).toCurrency()) " +
               LocalizationKeys.Accessibility.dollars.localized()
    }

    static let sampleSymbols: [StockSymbol] = [
        StockSymbol(symbol: "NVDA", name: "NVIDIA Corp.", description: "Graphics processing and AI chip manufacturer", currentPrice: 875.20, previousPrice: 870.45, lastUpdated: Date()),
        StockSymbol(symbol: "TMO", name: "Thermo Fisher Scientific", description: "Life sciences and laboratory equipment", currentPrice: 568.90, previousPrice: 566.30, lastUpdated: Date()),
        StockSymbol(symbol: "COST", name: "Costco Wholesale", description: "Membership-only warehouse club chain", currentPrice: 785.60, previousPrice: 782.40, lastUpdated: Date()),
        StockSymbol(symbol: "ADBE", name: "Adobe Inc.", description: "Creative software and digital marketing tools", currentPrice: 578.25, previousPrice: 576.10, lastUpdated: Date()),
        StockSymbol(symbol: "UNH", name: "UnitedHealth Group", description: "Healthcare and insurance services", currentPrice: 512.40, previousPrice: 510.80, lastUpdated: Date()),
        StockSymbol(symbol: "META", name: "Meta Platforms", description: "Social media and virtual reality company", currentPrice: 485.60, previousPrice: 487.20, lastUpdated: Date()),
        StockSymbol(symbol: "NFLX", name: "Netflix Inc.", description: "Streaming entertainment service", currentPrice: 445.80, previousPrice: 447.30, lastUpdated: Date()),
        StockSymbol(symbol: "MA", name: "Mastercard Inc.", description: "Global payment processing services", currentPrice: 445.75, previousPrice: 446.20, lastUpdated: Date()),
        StockSymbol(symbol: "BRK.B", name: "Berkshire Hathaway", description: "Warren Buffett's investment conglomerate", currentPrice: 445.30, previousPrice: 444.10, lastUpdated: Date()),
        StockSymbol(symbol: "MSFT", name: "Microsoft Corp.", description: "Software, cloud services, and productivity tools", currentPrice: 420.85, previousPrice: 419.50, lastUpdated: Date()),
        StockSymbol(symbol: "HD", name: "Home Depot Inc.", description: "Home improvement retail chain", currentPrice: 385.20, previousPrice: 383.70, lastUpdated: Date()),
        StockSymbol(symbol: "CRM", name: "Salesforce Inc.", description: "Cloud-based software and CRM services", currentPrice: 285.40, previousPrice: 283.90, lastUpdated: Date()),
        StockSymbol(symbol: "V", name: "Visa Inc.", description: "Global payments technology company", currentPrice: 275.80, previousPrice: 274.30, lastUpdated: Date()),
        StockSymbol(symbol: "TSLA", name: "Tesla Inc.", description: "Electric vehicle and clean energy company", currentPrice: 238.75, previousPrice: 240.10, lastUpdated: Date()),
        StockSymbol(symbol: "AAPL", name: "Apple Inc.", description: "Technology company known for iPhone, iPad, and Mac products", currentPrice: 185.50, previousPrice: 184.20, lastUpdated: Date()),
        StockSymbol(symbol: "ABBV", name: "AbbVie Inc.", description: "Pharmaceutical research and development", currentPrice: 178.90, previousPrice: 177.45, lastUpdated: Date()),
        StockSymbol(symbol: "PEP", name: "PepsiCo Inc.", description: "Food and beverage corporation", currentPrice: 172.35, previousPrice: 171.80, lastUpdated: Date()),
        StockSymbol(symbol: "PG", name: "Procter & Gamble", description: "Consumer goods and household products", currentPrice: 168.45, previousPrice: 167.90, lastUpdated: Date()),
        StockSymbol(symbol: "AMZN", name: "Amazon.com Inc.", description: "E-commerce and cloud computing giant", currentPrice: 156.90, previousPrice: 155.30, lastUpdated: Date()),
        StockSymbol(symbol: "JNJ", name: "Johnson & Johnson", description: "Pharmaceutical and consumer products", currentPrice: 152.90, previousPrice: 151.60, lastUpdated: Date()),
        StockSymbol(symbol: "GOOG", name: "Alphabet Inc.", description: "Google parent company, leader in search and cloud services", currentPrice: 142.30, previousPrice: 141.80, lastUpdated: Date()),
        StockSymbol(symbol: "XOM", name: "Exxon Mobil Corp.", description: "Oil and gas exploration and production", currentPrice: 118.75, previousPrice: 119.20, lastUpdated: Date()),
        StockSymbol(symbol: "DIS", name: "Walt Disney Company", description: "Entertainment and media conglomerate", currentPrice: 112.75, previousPrice: 113.20, lastUpdated: Date()),
        StockSymbol(symbol: "KO", name: "Coca-Cola Company", description: "Beverage manufacturing and distribution", currentPrice: 64.20, previousPrice: 63.95, lastUpdated: Date()),
        StockSymbol(symbol: "BAC", name: "Bank of America", description: "Major banking and financial services", currentPrice: 42.85, previousPrice: 42.60, lastUpdated: Date())
    ]
}
