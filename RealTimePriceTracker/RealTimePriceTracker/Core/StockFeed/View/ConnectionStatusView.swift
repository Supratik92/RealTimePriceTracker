//
//  ConnectionStatusView.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import SwiftUI

struct ConnectionStatusView: View {
    @EnvironmentObject private var webSocketService: WebSocketManager
    @State private var connectionState: NetworkConnectionState = .disconnected
    @State private var updateTrigger: UUID = UUID()

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(getStatusColor(for: connectionState))
                .frame(width: Constants.UI.connectionIndicatorSize, height: Constants.UI.connectionIndicatorSize)
                .accessibilityLabel(getStatusText(for: connectionState))

            Text(getStatusText(for: connectionState))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .task {
            connectionState = await webSocketService.connectionState
        }
        .task(id: updateTrigger) {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(500))
                let newState = await webSocketService.connectionState
                if newState != connectionState {
                    connectionState = newState
                }
            }
        }
        .onReceive(webSocketService.objectWillChange) { _ in
            updateTrigger = UUID()
        }
    }

    private func getStatusColor(for state: NetworkConnectionState) -> Color {
        switch state {
        case .connected:
            return .green
        case .connecting, .reconnecting:
            return .orange
        case .disconnected, .failed:
            return .red
        }
    }

    private func getStatusText(for state: NetworkConnectionState) -> String {
        switch state {
        case .connected:
            return LocalizationKeys.Connection.connected.localized()
        case .connecting:
            return LocalizationKeys.Connection.connecting.localized()
        case .reconnecting:
            return LocalizationKeys.Connection.reconnecting.localized()
        case .disconnected:
            return LocalizationKeys.Connection.disconnected.localized()
        case .failed:
            return LocalizationKeys.Connection.failed.localized()
        }
    }
}

