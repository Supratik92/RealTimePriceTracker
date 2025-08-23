//
//  SymbolDetailView.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import SwiftUI

struct SymbolDetailView: View {
    @StateObject private var viewModel: SymbolDetailViewModel
    @EnvironmentObject private var coordinator: AppCoordinator

    init(viewModel: SymbolDetailViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                priceCard
                descriptionCard
                infoCard
                Spacer()
            }
            .padding()
        }
        .navigationTitle(viewModel.symbol.symbol)
        .navigationBarTitleDisplayMode(.large)
    }

    private var priceCard: some View {
        VStack(spacing: Constants.UI.cardCornerRadius) {
            Text(viewModel.symbol.name)
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            VStack(spacing: 8) {
                Text("$\(viewModel.symbol.currentPrice.toCurrency())")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(viewModel.symbol.isFlashing ? viewModel.symbol.priceDirection.color : .primary)
                    .animation(.easeInOut(duration: Constants.UI.animationDuration), value: viewModel.symbol.isFlashing)
                    .accessibilityLabel(
                        LocalizationKeys.Accessibility.currentPrice.localized() +
                        " \(viewModel.symbol.currentPrice.toCurrency()) " +
                        LocalizationKeys.Accessibility.dollars.localized()
                    )

                PriceChangeView(symbol: viewModel.symbol)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .fill(Color(UIColor.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                        .stroke(viewModel.symbol.isFlashing ? viewModel.symbol.priceDirection.color : Color.clear, lineWidth: 2)
                        .animation(.easeInOut(duration: Constants.UI.animationDuration), value: viewModel.symbol.isFlashing)
                )
        )
    }

    private var descriptionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(LocalizationKeys.Symbol.about.localized())
                .font(.headline)

            Text(viewModel.symbol.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .accessibilityElement(children: .combine)
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: Constants.UI.cardCornerRadius) {
            Text(LocalizationKeys.Symbol.details.localized())
                .font(.headline)

            VStack(spacing: 12) {
                InfoRow(
                    label: LocalizationKeys.Symbol.lastUpdated.localized(),
                    value: DateFormatter.timeFormatter.string(from: viewModel.symbol.lastUpdated)
                )

                InfoRow(
                    label: LocalizationKeys.Symbol.previousPrice.localized(),
                    value: "$\(viewModel.symbol.previousPrice.toCurrency())"
                )

                InfoRow(
                    label: LocalizationKeys.Symbol.priceChange.localized(),
                    value: "\(viewModel.symbol.priceChange >= 0 ? "+" : "")\(viewModel.symbol.priceChange.toCurrency())"
                )

                InfoRow(
                    label: "Percentage Change",
                    value: viewModel.symbol.priceChangePercentage.toPercentage()
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Constants.UI.cardCornerRadius)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

