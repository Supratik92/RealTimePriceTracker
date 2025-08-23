//
//  StockRowView.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import SwiftUI

struct StockRowView: View {
    let symbol: StockSymbol
    let isFlashing: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(symbol.symbol)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("\(AccessibilityIdentifiers.StockRow.symbolText)_\(symbol.symbol)")

                Text(symbol.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .accessibilityIdentifier("\(AccessibilityIdentifiers.StockRow.nameText)_\(symbol.symbol)")
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(symbol.currentPrice.toCurrency())")
                    .font(.title3)
                    .fontWeight(.medium)
                    .accessibilityLabel(
                        LocalizationKeys.Accessibility.price.localized() +
                        " \(symbol.currentPrice.toCurrency()) " +
                        LocalizationKeys.Accessibility.dollars.localized()
                    )
                    .accessibilityIdentifier("\(AccessibilityIdentifiers.StockRow.priceText)_\(symbol.symbol)")

                HStack(spacing: 4) {
                    Text(symbol.priceDirection.arrow)
                        .foregroundColor(symbol.priceDirection.color)

                    Text("\(symbol.priceChange >= 0 ? "+" : "")\(symbol.priceChange.toCurrency())")
                        .font(.caption)
                        .foregroundColor(symbol.priceDirection.color)
                        .accessibilityIdentifier("\(AccessibilityIdentifiers.StockRow.changeText)_\(symbol.symbol)")
                }
                .accessibilityLabel(symbol.priceChangeAccessibilityLabel)
            }
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius / 2)
                .fill(isFlashing ? symbol.priceDirection.color.opacity(0.2) : Color.clear)
                .animation(.easeInOut(duration: Constants.UI.animationDuration), value: isFlashing)
        )
        .accessibilityElement(children: .combine)
        .accessibilityTapTarget()
    }
}
