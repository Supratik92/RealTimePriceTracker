//
//  String+Extension.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import Foundation

extension String {
    func localized(comment: String = .empty) -> String {
        return NSLocalizedString(self, comment: comment)
    }
}

extension StringLiteralType {
    static let empty = ""
}

