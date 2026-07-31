//
//  BrandComponents.swift
//  AutoCare
//

import SwiftUI

// MARK: - Card

struct BrandCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(BrandTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BrandTheme.Colors.backgroundSurface(colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: BrandTheme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BrandTheme.Radius.lg)
                    .stroke(BrandTheme.Colors.border(colorScheme), lineWidth: 1)
            )
    }
}

// MARK: - Detail Row

struct BrandDetailRow: View {
    let label: String
    let value: String
    var emphasized: Bool = false

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(
                    emphasized
                        ? BrandTheme.Typography.body(15, weight: .semibold)
                        : BrandTheme.Typography.caption(13)
                )
                .foregroundStyle(
                    emphasized
                        ? BrandTheme.Colors.textPrimary(colorScheme)
                        : BrandTheme.Colors.textMuted(colorScheme)
                )

            Spacer(minLength: BrandTheme.Spacing.md)

            Text(value)
                .font(BrandTheme.Typography.body(15, weight: emphasized ? .semibold : .regular))
                .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))
                .multilineTextAlignment(.trailing)
        }
    }
}

struct BrandReadOnlyCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        BrandFormCard { content }
    }
}

struct BrandFormCard<Content: View>: View {
    @Environment(\.colorScheme) private var colorScheme
    @ViewBuilder let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, BrandTheme.Spacing.md)
            .padding(.vertical, BrandTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BrandTheme.Colors.backgroundElevated(colorScheme))
            .clipShape(RoundedRectangle(cornerRadius: BrandTheme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: BrandTheme.Radius.lg)
                    .stroke(BrandTheme.Colors.border(colorScheme), lineWidth: 1)
            )
    }
}

struct BrandFormInputRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    @Environment(\.colorScheme) private var colorScheme

    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .center) {
            Text(label)
                .font(BrandTheme.Typography.body(15))
                .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))

            Spacer(minLength: BrandTheme.Spacing.md)

            content
        }
    }
}

struct BrandFormListRowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .listRowBackground(BrandTheme.Colors.backgroundSurface(colorScheme))
            .listRowSeparatorTint(BrandTheme.Colors.border(colorScheme))
    }
}

extension View {
    func brandFormListRow() -> some View {
        modifier(BrandFormListRowModifier())
    }
}

// MARK: - Section Header

struct BrandSectionHeader: View {
    let title: String
    var accent: Color = BrandTheme.Colors.violetSoft

    var body: some View {
        Text(title.uppercased())
            .font(BrandTheme.Typography.signature())
            .tracking(1.2)
            .foregroundStyle(accent)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Signature Badge

struct SignatureBadge: View {
    var body: some View {
        Text("BY ALLISTON")
            .font(BrandTheme.Typography.signature())
            .tracking(1.2)
            .foregroundStyle(BrandTheme.Colors.violetSoft)
    }
}

// MARK: - App Icon

struct BrandAppIcon: View {
    var size: CGFloat = 72

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(BrandTheme.brandGradient)
                .frame(width: size, height: size)

            BrandChevron()
                .frame(width: size * 0.45, height: size * 0.45)
        }
        .shadow(color: BrandTheme.Colors.violetCore.opacity(0.35), radius: 12, y: 6)
    }
}

struct BrandChevron: View {
    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            Path { path in
                path.move(to: CGPoint(x: w * 0.5, y: h * 0.08))
                path.addLine(to: CGPoint(x: w * 0.92, y: h * 0.92))
                path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.92))
                path.addLine(to: CGPoint(x: w * 0.5, y: h * 0.38))
                path.addLine(to: CGPoint(x: w * 0.28, y: h * 0.92))
                path.addLine(to: CGPoint(x: w * 0.08, y: h * 0.92))
                path.closeSubpath()
            }
            .fill(.white)
        }
    }
}

// MARK: - App Header

struct BrandAppHeader: View {
    let appName: String
    let tagline: String
    var iconSize: CGFloat = 72

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: BrandTheme.Spacing.md) {
            BrandAppIcon(size: iconSize)

            VStack(spacing: BrandTheme.Spacing.xs) {
                Text(appName)
                    .font(BrandTheme.Typography.display(28))
                    .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))

                Text(tagline)
                    .font(BrandTheme.Typography.body(15))
                    .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Text Field

struct BrandTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFocused: Bool

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
            }
        }
        .font(BrandTheme.Typography.body())
        .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))
        .padding(BrandTheme.Spacing.md)
        .background(BrandTheme.Colors.backgroundElevated(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: BrandTheme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: BrandTheme.Radius.md)
                .stroke(
                    isFocused ? BrandTheme.Colors.violetCore : BrandTheme.Colors.border(colorScheme),
                    lineWidth: isFocused ? 1.5 : 1
                )
        )
        .focused($isFocused)
    }
}

// MARK: - Version Badge

struct BrandBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(BrandTheme.Typography.caption(12))
            .foregroundStyle(BrandTheme.Colors.violetSoft)
            .padding(.horizontal, BrandTheme.Spacing.sm + 4)
            .padding(.vertical, BrandTheme.Spacing.xs)
            .background(BrandTheme.Colors.violetCore.opacity(0.15))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(BrandTheme.Colors.violetSoft.opacity(0.4), lineWidth: 1)
            )
    }
}

// MARK: - List Row

struct BrandListRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?

    @Environment(\.colorScheme) private var colorScheme

    init(icon: String, iconColor: Color = BrandTheme.Colors.violetSoft, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: BrandTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(BrandTheme.Typography.body(15))
                    .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))

                if let subtitle {
                    Text(subtitle)
                        .font(BrandTheme.Typography.caption(13))
                        .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
        }
    }
}

// MARK: - Empty State

struct BrandEmptyState: View {
    let icon: String
    let title: String
    let message: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: BrandTheme.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(BrandTheme.Colors.violetSoft)

            Text(title)
                .font(BrandTheme.Typography.heading())
                .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))

            Text(message)
                .font(BrandTheme.Typography.body(14))
                .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
                .multilineTextAlignment(.center)
        }
        .padding(BrandTheme.Spacing.xl)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Vehicle Title Button

struct BrandLargeVehicleTitle: View {
    let title: String
    let action: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button(action: action) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(title)
                    .font(BrandTheme.Typography.display(34))
                    .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Image(systemName: "chevron.down")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
                    .offset(y: 4)
            }
        }
        .buttonStyle(.plain)
    }
}

struct BrandScreenHeader<Trailing: View>: View {
    let title: String
    let onTitleTap: () -> Void
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        HStack(alignment: .center, spacing: BrandTheme.Spacing.md) {
            BrandLargeVehicleTitle(title: title, action: onTitleTap)

            Spacer(minLength: BrandTheme.Spacing.sm)

            trailing()
        }
        .padding(.horizontal, BrandTheme.Spacing.md)
        .padding(.top, BrandTheme.Spacing.sm)
        .padding(.bottom, BrandTheme.Spacing.md)
    }
}

struct BrandToolbarIconButton: View {
    let systemName: String

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 17, weight: .medium))
            .foregroundStyle(BrandTheme.Colors.violetCore)
            .frame(width: 36, height: 36)
            .background(BrandTheme.Colors.backgroundSurface(colorScheme))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(BrandTheme.Colors.border(colorScheme), lineWidth: 1)
            )
    }
}

// MARK: - Vehicle Picker

struct VehiclePickerSheet: View {
    let vehicles: [Vehicle]
    let selectedVehicle: Vehicle?
    let onSelect: (Vehicle) -> Void
    let onAddVehicle: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: BrandTheme.Spacing.sm) {
                    BrandSectionHeader(title: "Seus veículos", accent: BrandTheme.Colors.violetSoft)
                        .padding(.horizontal, BrandTheme.Spacing.lg)
                        .padding(.top, BrandTheme.Spacing.sm)

                    ForEach(vehicles, id: \.clientId) { vehicle in
                        Button {
                            onSelect(vehicle)
                        } label: {
                            VehiclePickerRow(
                                vehicle: vehicle,
                                isSelected: vehicle.clientId == selectedVehicle?.clientId
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, BrandTheme.Spacing.lg)
                    }

                    Button(action: onAddVehicle) {
                        HStack(spacing: BrandTheme.Spacing.md) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(BrandTheme.Colors.violetCore)

                            Text("Adicionar veículo")
                                .font(BrandTheme.Typography.body(15, weight: .medium))
                                .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))

                            Spacer()
                        }
                        .padding(BrandTheme.Spacing.md)
                        .background(BrandTheme.Colors.backgroundSurface(colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: BrandTheme.Radius.lg))
                        .overlay(
                            RoundedRectangle(cornerRadius: BrandTheme.Radius.lg)
                                .stroke(BrandTheme.Colors.border(colorScheme), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, BrandTheme.Spacing.lg)
                    .padding(.top, BrandTheme.Spacing.sm)
                }
                .padding(.bottom, BrandTheme.Spacing.lg)
            }
            .brandBackground()
            .navigationTitle("Selecionar veículo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                        .foregroundStyle(BrandTheme.Colors.violetCore)
                }
            }
        }
        .tint(BrandTheme.Colors.violetCore)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

struct VehiclePickerRow: View {
    let vehicle: Vehicle
    let isSelected: Bool

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: BrandTheme.Spacing.md) {
            Image(systemName: "car.fill")
                .font(.system(size: 18))
                .foregroundStyle(isSelected ? BrandTheme.Colors.violetCore : BrandTheme.Colors.violetSoft)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(vehicle.name)
                    .font(BrandTheme.Typography.body(15, weight: .semibold))
                    .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))

                Text("\(vehicle.brand) \(vehicle.model) · \(vehicle.licensePlate)")
                    .font(BrandTheme.Typography.caption(13))
                    .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
            }

            Spacer(minLength: 0)

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(BrandTheme.Colors.violetCore)
            }
        }
        .padding(BrandTheme.Spacing.md)
        .background(BrandTheme.Colors.backgroundSurface(colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: BrandTheme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: BrandTheme.Radius.lg)
                .stroke(
                    isSelected ? BrandTheme.Colors.violetCore.opacity(0.5) : BrandTheme.Colors.border(colorScheme),
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
    }
}

// MARK: - Tab Header

struct BrandTabHeader: View {
    let title: String
    let subtitle: String
    var accent: Color = BrandTheme.Colors.violetSoft

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: BrandTheme.Spacing.xs) {
            BrandSectionHeader(title: title, accent: accent)

            Text(subtitle)
                .font(BrandTheme.Typography.body(15))
                .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, BrandTheme.Spacing.lg)
        .padding(.top, BrandTheme.Spacing.sm)
        .padding(.bottom, BrandTheme.Spacing.xs)
    }
}

// MARK: - Floating Add Button

struct BrandAddToolbarButton: View {
    var body: some View {
        Image(systemName: "plus")
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(BrandTheme.Colors.violetCore)
    }
}
