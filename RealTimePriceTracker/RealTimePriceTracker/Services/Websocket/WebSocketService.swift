//
//  WebSocketService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation
import Combine

protocol WebSocketService: ObservableObject {
    var isConnected: Bool { get }
    var connectionError: NetworkError? { get }
    var connectionState: AnyPublisher<NetworkConnectionState, Never> { get }
    var priceUpdates: AnyPublisher<PriceUpdate, Never> { get }

    func connect() -> AnyPublisher<Void, NetworkError>
    func disconnect()
    func sendPriceUpdate(_ update: PriceUpdate) -> AnyPublisher<Void, NetworkError>
}
