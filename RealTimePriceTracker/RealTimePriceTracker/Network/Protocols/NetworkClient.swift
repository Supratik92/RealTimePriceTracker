//
//  NetworkClient.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation
import Combine

protocol NetworkClient: AnyObject {
    var isConnected: Bool { get }
    var connectionState: AnyPublisher<NetworkConnectionState, Never> { get }

    func connect(to url: URL) -> AnyPublisher<Void, NetworkError>
    func disconnect()
    func send<T: Codable>(_ data: T) -> AnyPublisher<Void, NetworkError>
    func receive<T: Codable>(_ type: T.Type) -> AnyPublisher<T, NetworkError>
}
