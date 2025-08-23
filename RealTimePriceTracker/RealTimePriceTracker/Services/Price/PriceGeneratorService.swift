//
//  PriceGeneratorService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation
import Combine

protocol PriceGeneratorService: AnyObject {
    var isGenerating: Bool { get }

    func startGenerating(for symbols: [StockSymbol]) -> AnyPublisher<Void, PriceGeneratorError>
    func stopGenerating()
}
