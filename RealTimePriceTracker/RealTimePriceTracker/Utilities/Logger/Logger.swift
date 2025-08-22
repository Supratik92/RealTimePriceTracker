//
//  Logger.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Combine

protocol Logger: ObservableObject {
    func debug(_ message: String, category: LogCategory)
    func info(_ message: String, category: LogCategory)
    func warning(_ message: String, category: LogCategory)
    func error(_ message: String, error: Error?, category: LogCategory)
}
