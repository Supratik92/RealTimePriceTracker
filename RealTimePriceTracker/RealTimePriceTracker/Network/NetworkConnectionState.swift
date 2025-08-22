//
//  NetworkConnectionState.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

enum NetworkConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case reconnecting
    case failed(NetworkError)

    static func == (lhs: NetworkConnectionState, rhs: NetworkConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.disconnected, .disconnected),
             (.connecting, .connecting),
             (.connected, .connected),
             (.reconnecting, .reconnecting):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}
