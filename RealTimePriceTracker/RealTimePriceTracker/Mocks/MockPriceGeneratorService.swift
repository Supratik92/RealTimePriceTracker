//
//  MockPriceGeneratorService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import SwiftUI

final class MockPriceGeneratorService: PriceGeneratorService {

    @MainActor private var _isGenerating = false

    var isGenerating: Bool {
        get async {
            await MainActor.run { _isGenerating }
        }
    }

    @MainActor var startGeneratingCalled = false
    @MainActor var stopGeneratingCalled = false
    @MainActor var shouldSucceedGeneration = true

    nonisolated func startGenerating(for symbols: [StockSymbol]) async throws {
        try await MainActor.run {
            startGeneratingCalled = true

            if shouldSucceedGeneration {
                _isGenerating = true
            } else {
                throw PriceGeneratorError.generationFailed("Mock generation failed")
            }
        }
    }

    nonisolated func stopGenerating() async {
        await MainActor.run {
            stopGeneratingCalled = true
            _isGenerating = false
        }
    }
}
