//
//  View+Extension.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 22/08/25.
//

import SwiftUI

extension View {
    func errorAlert(error: Binding<NetworkError?>,
                    onRetry: @escaping () -> Void = {}) -> some View {
        alert(LocalizationKeys.Errors.title.localized(), isPresented: .constant(error.wrappedValue != nil)) {
            Button(LocalizationKeys.Buttons.ok.localized()) {
                error.wrappedValue = nil
            }
            Button(LocalizationKeys.Buttons.retry.localized()) {
                onRetry()
                error.wrappedValue = nil
            }
        } message: {
            Text(error.wrappedValue?.localizedDescription ?? .empty)
        }
    }

    func accessibilityTapTarget() -> some View {
        frame(minWidth: Constants.UI.minimumTapTarget, minHeight: Constants.UI.minimumTapTarget)
    }
}
