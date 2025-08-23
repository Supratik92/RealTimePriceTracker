//
//  MockLogger.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Combine
import Foundation

final class MockLogger: Logger, ObservableObject {
    struct LogEntry {
        let level: String
        let message: String
        let category: LogCategory
        let error: Error?
        let timestamp: Date
    }

    var logs: [LogEntry] = []

    func debug(_ message: String, category: LogCategory = .business) {
        logs.append(LogEntry(level: "DEBUG", message: message, category: category, error: nil, timestamp: Date()))
    }

    func info(_ message: String, category: LogCategory = .business) {
        logs.append(LogEntry(level: "INFO", message: message, category: category, error: nil, timestamp: Date()))
    }

    func warning(_ message: String, category: LogCategory = .business) {
        logs.append(LogEntry(level: "WARNING", message: message, category: category, error: nil, timestamp: Date()))
    }

    func error(_ message: String, error: Error? = nil, category: LogCategory = .business) {
        logs.append(LogEntry(level: "ERROR", message: message, category: category, error: error, timestamp: Date()))
    }

    func clearLogs() {
        logs.removeAll()
    }

    func logsForCategory(_ category: LogCategory) -> [LogEntry] {
        logs.filter { $0.category == category }
    }
}
