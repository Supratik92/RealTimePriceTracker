//
//  StockFeedView.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import SwiftUI

struct StockFeedView: View {
    @StateObject private var viewModel: StockFeedViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @State private var showingErrorAlert = false

    init(viewModel: StockFeedViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar

            if let errorMessage = viewModel.errorMessage {
                errorBanner(errorMessage)
            }

            stockList
        }
        .navigationTitle(LocalizationKeys.App.title.localized())
        .navigationBarTitleDisplayMode(.large)
    }

    private var topBar: some View {
        HStack {
            ConnectionStatusView()
            Spacer()
            TrackingControlButton(
                isActive: viewModel.isTrackingActive,
                isLoading: viewModel.isLoading,
                onStart: {
                    Task {
                        await viewModel.startTracking()
                    }
                },
                onStop: {
                    Task {
                        await viewModel.stopTracking()
                    }
                }
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: Constants.UI.separatorHeight)
                .foregroundColor(Color(UIColor.separator)),
            alignment: .bottom
        )
    }

    private func errorBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)

            Text(message)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            Spacer()

            Button(LocalizationKeys.Buttons.dismiss.localized()) {
                viewModel.errorMessage = nil
            }
            .font(.caption)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(LocalizationKeys.Accessibility.errorBanner.localized() + ": \(message)")
    }

    private var stockList: some View {
        List(viewModel.symbols) { symbol in
            StockRowView(symbol: symbol, isFlashing: viewModel.flashingSymbols.contains(symbol.symbol))
                .onTapGesture {
                    Task {
                        await coordinator.navigate(to: .symbolDetail(symbol))
                    }
                }
                .accessibilityElement(children: .combine)
                .accessibilityAction(named: LocalizationKeys.Accessibility.viewDetails.localized()) {
                    Task {
                        await coordinator.navigate(to: .symbolDetail(symbol))
                    }
                }
        }
        .listStyle(PlainListStyle())
        .refreshable {
            await viewModel.refreshData()
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(Constants.UI.progressViewScale)
                    .accessibilityLabel(LocalizationKeys.Accessibility.loading.localized())
            }
        }
    }
}
