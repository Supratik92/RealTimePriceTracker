//
//  NetworkClient.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

protocol NetworkClient: AnyObject {
    var isConnected: Bool { get async }
    var connectionState: NetworkConnectionState { get async }

    func connect(to url: URL) async throws
    func disconnect() async
    func send<T: Codable>(_ data: T) async throws
    func startReceiving<T: Codable>(_ type: T.Type) -> AsyncThrowingStream<T, Error>
}
