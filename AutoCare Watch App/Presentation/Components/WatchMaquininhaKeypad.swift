//
//  WatchMaquininhaKeypad.swift
//  AutoCare Watch App
//

import SwiftUI

struct WatchMaquininhaKeypad: View {
    @Binding var rawValue: Int
    let maxRaw: Int
    let display: String
    let caption: String
    let progressIndex: Int?
    let navigationTitle: String
    let canContinue: Bool
    let onContinue: () -> Void
    var footer: AnyView?

    init(
        rawValue: Binding<Int>,
        maxRaw: Int,
        display: String,
        caption: String,
        progressIndex: Int?,
        navigationTitle: String,
        canContinue: Bool,
        onContinue: @escaping () -> Void,
        footer: AnyView? = nil
    ) {
        _rawValue = rawValue
        self.maxRaw = maxRaw
        self.display = display
        self.caption = caption
        self.progressIndex = progressIndex
        self.navigationTitle = navigationTitle
        self.canContinue = canContinue
        self.onContinue = onContinue
        self.footer = footer
    }

    var body: some View {
        VStack(spacing: 4) {
            if let progressIndex {
                WatchProgressDots(index: progressIndex)
            }

            Text(display)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(caption)
                .font(.caption2)
                .foregroundStyle(.secondary)

            if let footer {
                footer
            }

            keypad
        }
        .navigationTitle(navigationTitle)
    }

    private var keypad: some View {
        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            GridRow {
                digit(1)
                digit(2)
                digit(3)
            }
            GridRow {
                digit(4)
                digit(5)
                digit(6)
            }
            GridRow {
                digit(7)
                digit(8)
                digit(9)
            }
            GridRow {
                keyButton(systemImage: "delete.left") {
                    rawValue /= 10
                }
                digit(0)
                Button("OK", action: onContinue)
                    .buttonStyle(.plain)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        WatchTheme.violet.opacity(canContinue ? 1 : 0.35),
                        in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                    )
                    .disabled(!canContinue)
            }
        }
    }

    private func digit(_ value: Int) -> some View {
        keyButton(title: "\(value)") {
            let next = (rawValue * 10) + value
            guard next <= maxRaw else { return }
            rawValue = next
        }
    }

    private func keyButton(title: String? = nil, systemImage: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                if let title {
                    Text(title)
                        .font(.title3.weight(.medium))
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.body.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primary.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
