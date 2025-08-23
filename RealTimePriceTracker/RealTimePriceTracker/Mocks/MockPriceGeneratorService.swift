//
//  MockPriceGeneratorService.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Combine
import Foundation

final class MockPriceGeneratorService: PriceGeneratorService {
    @Published private var _isGenerating = false

    var isGenerating: Bool { _isGenerating }

    var startGeneratingCalled = false
    var stopGeneratingCalled = false
    var shouldSucceedGeneration = true

    func startGenerating(for symbols: [StockSymbol]) -> AnyPublisher<Void, PriceGeneratorError> {
        return Future<Void, PriceGeneratorError> { promise in
            self.startGeneratingCalled = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if self.shouldSucceedGeneration {
                    self._isGenerating = true
                    promise(.success(()))
                } else {
                    promise(.failure(.generationFailed("Mock generation failed")))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func stopGenerating() {
        stopGeneratingCalled = true
        _isGenerating = false
    }
}
