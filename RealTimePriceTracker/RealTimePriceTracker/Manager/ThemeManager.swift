//
//  ThemeManager.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme?

    enum Theme: String, CaseIterable {
        case system = "system"
        case light = "light"
        case dark = "dark"

        var displayName: String {
            switch self {
            case .system: return LocalizationKeys.Theme.system.localized()
            case .light: return LocalizationKeys.Theme.light.localized()
            case .dark: return LocalizationKeys.Theme.dark.localized()
            }
        }

        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }

    @Published var currentTheme: Theme = .system {
        didSet {
            colorScheme = currentTheme.colorScheme
            UserDefaults.standard.set(currentTheme.rawValue, forKey: Constants.UserDefaults.selectedTheme)
        }
    }

    init() {
        loadSavedTheme()
    }

    private func loadSavedTheme() {
        if let savedTheme = UserDefaults.standard.string(forKey: Constants.UserDefaults.selectedTheme),
           let theme = Theme(rawValue: savedTheme) {
            currentTheme = theme
        }
        colorScheme = currentTheme.colorScheme
    }
}
