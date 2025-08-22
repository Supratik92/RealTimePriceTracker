//
//  ConsoleLogger.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Combine
import OSLog

final class ConsoleLogger: Logger, ObservableObject {
    func debug(_ message: String, category: LogCategory = .business) {
        os_log("%{public}@", log: category.osLog, type: .debug, LogHelpers.formatMessage(message, level: "DEBUG", category: category))
    }

    func info(_ message: String, category: LogCategory = .business) {
        os_log("%{public}@", log: category.osLog, type: .info, LogHelpers.formatMessage(message, level: "INFO", category: category))
    }

    func warning(_ message: String, category: LogCategory = .business) {
        os_log("%{public}@", log: category.osLog, type: .default, LogHelpers.formatMessage(message, level: "WARNING", category: category))
    }

    func error(_ message: String, error: Error? = nil, category: LogCategory = .business) {
        let fullMessage = LogHelpers.formatErrorMessage(message, error: error)
        os_log("%{public}@", log: category.osLog, type: .error, LogHelpers.formatMessage(fullMessage, level: "ERROR", category: category))
    }
}
