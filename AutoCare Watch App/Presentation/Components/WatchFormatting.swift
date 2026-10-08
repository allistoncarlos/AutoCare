//
//  WatchFormatting.swift
//  AutoCare Watch App
//

import SwiftUI

enum WatchTheme {
    static let violet = Color(red: 0.486, green: 0.227, blue: 0.929)
    static let success = Color(red: 0.133, green: 0.773, blue: 0.369)
}

enum WatchNumberFormatting {
    static func currency(cents: Int) -> String {
        let safe = max(cents, 0)
        let reais = safe / 100
        let centavos = safe % 100
        return "R$ \(reais),\(String(format: "%02d", centavos))"
    }

    static func grouped(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func kilometers(_ value: Int) -> String {
        "\(grouped(value)) km"
    }

    static func liters(milliLiters: Int) -> String {
        let value = Double(milliLiters) / 1_000.0
        return String(format: "%.3f L", value).replacingOccurrences(of: ".", with: ",")
    }

    static func consumption(_ value: Double) -> (number: String, unit: String) {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        let number = formatter.string(from: NSNumber(value: value)) ?? "0,0"
        return (number, "km/L")
    }
}

struct WatchPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        WatchPrimaryButtonLabel(configuration: configuration)
    }
}

private struct WatchPrimaryButtonLabel: View {
    let configuration: ButtonStyleConfiguration
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                WatchTheme.violet.opacity(isEnabled ? 1 : 0.35),
                in: Capsule()
            )
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

struct WatchProgressDots: View {
    let index: Int
    private let count = 4

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<count, id: \.self) { dot in
                Circle()
                    .fill(dot == index ? WatchTheme.violet : Color.primary.opacity(0.25))
                    .frame(width: 6, height: 6)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

