//
//  PriceGeneratorService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

protocol PriceGeneratorService: AnyObject {
    var isGenerating: Bool { get async }

    func startGenerating(for symbols: [StockSymbol]) async throws
    func stopGenerating() async
}
