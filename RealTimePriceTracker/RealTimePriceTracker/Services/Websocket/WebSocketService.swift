//
//  WebSocketService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

@MainActor
protocol WebSocketService: ObservableObject {
    var isConnected: Bool { get async }
    var connectionError: NetworkError? { get }
    var connectionState: NetworkConnectionState { get async }

    nonisolated func connect() async throws
    nonisolated func disconnect() async
    nonisolated func sendPriceUpdate(_ update: PriceUpdate) async throws
    nonisolated func startPriceUpdateStream() -> AsyncThrowingStream<PriceUpdate, Error>
}
