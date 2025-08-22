//
//  LogHelpers.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

struct LogHelpers {
    static func formatMessage(_ message: String, level: String, category: LogCategory) -> String {
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        return "[\(timestamp)] [\(level)] [\(category.rawValue)] \(message)"
    }

    static func formatErrorMessage(_ message: String, error: Error?) -> String {
        guard let error = error else { return message }
        return "\(message) - Error: \(error.localizedDescription)"
    }
}
