//
//  PriceDirection.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import SwiftUI

enum PriceDirection {
    case up, down, neutral

    var color: Color {
        switch self {
        case .up: return .green
        case .down: return .red
        case .neutral: return .secondary
        }
    }

    var arrow: String {
        switch self {
        case .up: return "↑"
        case .down: return "↓"
        case .neutral: return "→"
        }
    }
}
