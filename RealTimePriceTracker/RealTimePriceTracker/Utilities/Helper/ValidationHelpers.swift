//
//  ValidationHelpers.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

struct ValidationHelpers {
    static func validateSymbolCode(_ code: String) -> Bool {
        return !code.isEmpty && code.allSatisfy { $0.isLetter || $0 == "." }
    }

    static func validatePrice(_ price: Double) -> Bool {
        return price >= Constants.PriceGeneration.minimumPrice &&
               price <= Constants.PriceGeneration.maximumPrice &&
               price.isFinite
    }
}
