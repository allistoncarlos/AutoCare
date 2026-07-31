//
//  MainButtonStyle.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 21/02/24.
//

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandTheme.Typography.body(16, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.vertical, BrandTheme.Spacing.md)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(buttonBackground(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: BrandTheme.Radius.md))
            .shadow(
                color: isEnabled ? BrandTheme.Colors.violetCore.opacity(0.3) : .clear,
                radius: 8,
                y: 4
            )
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    @ViewBuilder
    private func buttonBackground(isPressed: Bool) -> some View {
        if isEnabled {
            BrandTheme.brandGradient
                .opacity(isPressed ? 0.85 : 1)
        } else {
            BrandTheme.Colors.textMuted(colorScheme).opacity(0.4)
        }
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandTheme.Typography.body(16, weight: .medium))
            .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))
            .padding(.vertical, BrandTheme.Spacing.md)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(BrandTheme.Colors.backgroundSurface(colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: BrandTheme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: BrandTheme.Radius.md)
                    .stroke(BrandTheme.Colors.border(colorScheme), lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
