//
//  PriceChangeView.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import SwiftUI

struct PriceChangeView: View {
    let symbol: StockSymbol

    var body: some View {
        HStack(spacing: 8) {
            Text(symbol.priceDirection.arrow)
                .font(.title2)
                .foregroundColor(symbol.priceDirection.color)

            Text("\(symbol.priceChange >= 0 ? "+" : "")\(symbol.priceChange.toCurrency())")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(symbol.priceDirection.color)

            Text("(\(symbol.priceChangePercentage >= 0 ? "+" : "")\(symbol.priceChangePercentage.toPercentage()))")
                .font(.caption)
                .foregroundColor(symbol.priceDirection.color)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(symbol.priceChangeAccessibilityLabel)
    }
}
