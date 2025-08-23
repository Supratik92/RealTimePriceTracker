//
//  TrackingControlButton.swift
//  RealTimePriceTracker
//
//  Created by Supratik Banerjee on 23/08/25.
//

import SwiftUI

struct TrackingControlButton: View {
    let isActive: Bool
    let isLoading: Bool
    let onStart: () -> Void
    let onStop: () -> Void

    var body: some View {
        Button(action: {
            if isActive {
                onStop()
            } else {
                onStart()
            }
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: isActive ? "stop.fill" : "play.fill")
                }

                Text(isActive ?
                    LocalizationKeys.Buttons.stop.localized() :
                    LocalizationKeys.Buttons.start.localized()
                )
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, Constants.UI.buttonCornerRadius)
            .padding(.vertical, 8)
            .background(isActive ? Color.red : Color.green)
            .cornerRadius(Constants.UI.buttonCornerRadius)
        }
        .disabled(isLoading)
        .accessibilityLabel(isActive ?
            LocalizationKeys.Accessibility.stopTracking.localized() :
            LocalizationKeys.Accessibility.startTracking.localized()
        )
        .accessibilityTapTarget()
    }
}

