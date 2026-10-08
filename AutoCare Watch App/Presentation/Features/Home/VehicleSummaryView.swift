//
//  VehicleSummaryView.swift
//  AutoCare Watch App
//

import SwiftUI

struct VehicleSummaryView: View {
    let vehicle: WatchVehicle
    let canSwitch: Bool
    let onSwitch: () -> Void
    let onFuel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Último abastecimento")
                .font(.caption)
                .foregroundStyle(.secondary)

            card(title: "Odômetro", value: odometerText)
            card(title: "Preço/L", value: priceText)

            Spacer(minLength: 0)

            if canSwitch {
                Button("Trocar veículo", action: onSwitch)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
                    .buttonStyle(.plain)
            }

            Button("Abastecer", action: onFuel)
                .buttonStyle(WatchPrimaryButtonStyle())
        }
        .navigationTitle(vehicle.name)
        .onAppear {
            WatchVehicleSelectionStore.remember(vehicle.id)
        }
    }

    private var odometerText: String {
        guard let odometer = vehicle.lastOdometer else { return "—" }
        return WatchNumberFormatting.kilometers(odometer)
    }

    private var priceText: String {
        guard let price = vehicle.lastFuelCost else { return "—" }
        return WatchNumberFormatting.currency(cents: Int((price * 100).rounded()))
    }

    private func card(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
