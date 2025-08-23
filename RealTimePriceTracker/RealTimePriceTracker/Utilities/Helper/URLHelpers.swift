//
//  URLHelpers.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import Foundation

struct URLHelpers {
    static func extractPathComponents(from url: URL) -> [String] {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        return components?.path.components(separatedBy: "/").filter { !$0.isEmpty } ?? []
    }

    static func createDeepLinkURL(for symbol: String) -> URL? {
        return URL(string: "\(Constants.DeepLink.scheme)://\(Constants.DeepLink.symbolPath)/\(symbol)")
    }
}
