//
//  Double+Extensions.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

extension Double {
    func toCurrency() -> String {
        return String(format: "%.2f", self)
    }

    func toPercentage() -> String {
        return String(format: "%.2f%%", self)
    }
}
