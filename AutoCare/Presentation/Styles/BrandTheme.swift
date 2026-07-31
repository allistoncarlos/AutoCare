//
//  BrandTheme.swift
//  AutoCare
//
//  Design tokens — Alliston Aleixo Visual Identity v1.0
//

import SwiftUI
import UIKit

enum BrandTheme {

    // MARK: - Brand Colors

    enum Colors {
        static let violetCore = Color(hex: 0x7C3AED)
        static let violetDeep = Color(hex: 0x5B21B6)
        static let violetSoft = Color(hex: 0xA78BFA)
        static let gradientStart = Color(hex: 0x7C3AED)
        static let gradientEnd = Color(hex: 0x6366F1)
        static let utility = Color(hex: 0x6366F1)
        static let productivity = Color(hex: 0x14B8A6)
        static let success = Color(hex: 0x22C55E)
        static let error = Color(hex: 0xEF4444)
        static let warning = Color(hex: 0xF59E0B)

        static func backgroundPrimary(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? Color(hex: 0x0A0A0F) : Color(hex: 0xFAFAFA)
        }

        static func backgroundSurface(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? Color(hex: 0x14141F) : Color(hex: 0xFFFFFF)
        }

        static func backgroundElevated(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? Color(hex: 0x1E1E2E) : Color(hex: 0xF4F4F5)
        }

        static func border(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? Color(hex: 0x2A2A3C) : Color(hex: 0xE4E4E7)
        }

        static func textPrimary(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? Color(hex: 0xF4F4F5) : Color(hex: 0x18181B)
        }

        static func textMuted(_ scheme: ColorScheme) -> Color {
            scheme == .dark ? Color(hex: 0xA1A1AA) : Color(hex: 0x71717A)
        }
    }

    // MARK: - Spacing & Radius

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
    }

    // MARK: - Typography

    enum FontFamily {
        static let interRegular = "Inter-Regular"
        static let interMedium = "Inter-Medium"
        static let interSemiBold = "Inter-SemiBold"
        static let jakartaSemiBold = "PlusJakartaSans-SemiBold"
        static let jakartaBold = "PlusJakartaSans-Bold"
    }

    enum BodyWeight {
        case regular
        case medium
        case semibold

        var postScriptName: String {
            switch self {
            case .regular:
                FontFamily.interRegular
            case .medium:
                FontFamily.interMedium
            case .semibold:
                FontFamily.interSemiBold
            }
        }

        var uiWeight: UIFont.Weight {
            switch self {
            case .regular:
                .regular
            case .medium:
                .medium
            case .semibold:
                .semibold
            }
        }
    }

    enum Typography {
        static func display(_ size: CGFloat = 32) -> Font {
            custom(FontFamily.jakartaBold, size: size)
        }

        static func heading(_ size: CGFloat = 20) -> Font {
            custom(FontFamily.jakartaSemiBold, size: size)
        }

        static func body(_ size: CGFloat = 16, weight: BodyWeight = .regular) -> Font {
            custom(weight.postScriptName, size: size)
        }

        static func caption(_ size: CGFloat = 13) -> Font {
            custom(FontFamily.interMedium, size: size)
        }

        static func signature() -> Font {
            custom(FontFamily.interMedium, size: 11)
        }

        static func mono(_ size: CGFloat = 14) -> Font {
            .system(size: size, weight: .regular, design: .monospaced)
        }

        /// Apenas para pontes UIKit (`CurrencyUITextField`, `UITabBarAppearance`).
        static func uiFontBody(size: CGFloat = 16, weight: BodyWeight = .regular) -> UIFont {
            uiFont(named: weight.postScriptName, size: size, fallbackWeight: weight.uiWeight)
        }

        static func uiFontDisplay(size: CGFloat, bold: Bool = false) -> UIFont {
            let name = bold ? FontFamily.jakartaBold : FontFamily.jakartaSemiBold
            let fallbackWeight: UIFont.Weight = bold ? .bold : .semibold
            return uiFont(named: name, size: size, fallbackWeight: fallbackWeight)
        }

        private static func custom(_ name: String, size: CGFloat) -> Font {
            .custom(name, size: size)
        }

        private static func uiFont(
            named name: String,
            size: CGFloat,
            fallbackWeight: UIFont.Weight
        ) -> UIFont {
            UIFont(name: name, size: size)
                ?? .systemFont(ofSize: size, weight: fallbackWeight)
        }
    }

    // MARK: - Gradients

    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [Colors.gradientStart, Colors.gradientEnd],
            startPoint: .bottomLeading,
            endPoint: .topTrailing
        )
    }
}

// MARK: - Color Hex

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: - View Modifiers

struct BrandBackgroundModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(BrandTheme.Colors.backgroundPrimary(colorScheme).ignoresSafeArea())
    }
}

struct BrandScreenModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(BrandTheme.Colors.backgroundPrimary(colorScheme))
            .scrollContentBackground(.hidden)
    }
}

struct BrandNavigationModifier: ViewModifier {
    let title: String?
    var displayMode: NavigationBarItem.TitleDisplayMode = .inline
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .navigationTitle(title ?? "")
            .navigationBarTitleDisplayMode(displayMode)
            .toolbarBackground(BrandTheme.Colors.backgroundSurface(colorScheme), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(colorScheme == .dark ? .dark : .light, for: .navigationBar)
    }
}

struct BrandTypographyModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.environment(\.font, BrandTheme.Typography.body())
    }
}

extension View {
    func brandBackground() -> some View {
        modifier(BrandBackgroundModifier())
    }

    func brandScreen() -> some View {
        modifier(BrandScreenModifier())
    }

    func brandNavigation(
        title: String?,
        displayMode: NavigationBarItem.TitleDisplayMode = .inline
    ) -> some View {
        modifier(BrandNavigationModifier(title: title, displayMode: displayMode))
    }

    func brandTypography() -> some View {
        modifier(BrandTypographyModifier())
    }
}
