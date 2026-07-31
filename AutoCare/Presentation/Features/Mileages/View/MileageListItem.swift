//
//  MileageListItem.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 19/03/24.
//

import SwiftUI

struct MileageListItem: View {
    var vehicleMileage: VehicleMileage

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            leadingColumn
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            trailingColumn
                .fixedSize(horizontal: true, vertical: false)
        }
    }

    private var leadingColumn: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Image(systemName: "fuelpump.fill")
                    .font(.subheadline)
                    .foregroundStyle(BrandTheme.Colors.violetSoft)

                if let liters = vehicleMileage.liters.toLeadingZerosString(decimalPlaces: 3) {
                    Text("\(liters) L")
                        .font(.body)
                        .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))
                }
            }

            Text(vehicleMileage.date.toFormattedString(dateFormat: AutoCareApp.dateFormat))
                .font(.subheadline)
                .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))

            if let calculatedMileage = vehicleMileage.calculatedMileage.toLeadingZerosString(decimalPlaces: 3) {
                Text("\(calculatedMileage) km/L")
                    .font(.subheadline)
                    .foregroundStyle(BrandTheme.Colors.violetSoft)
            }
        }
    }

    private var trailingColumn: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if let totalCost = vehicleMileage.totalCost.toCurrencyString() {
                Text(totalCost)
                    .font(.body)
                    .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))
            }

            Text("\(vehicleMileage.odometerDifference) km")
                .font(.subheadline)
                .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))

            if let fuelCost = vehicleMileage.fuelCost.toCurrencyString() {
                Text("\(fuelCost)/L")
                    .font(.subheadline)
                    .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
            }
        }
    }
}

#Preview {
    List {
        MileageListItem(
            vehicleMileage: VehicleMileage(
                id: "123",
                date: Date(),
                totalCost: 131.55,
                odometer: 685,
                odometerDifference: 250,
                liters: 22.720,
                fuelCost: 5.97,
                calculatedMileage: 11.0,
                complete: true,
                vehicleId: "65f7489acdac2f577161d7f7"
            )
        )
        .brandFormListRow()

        MileageListItem(
            vehicleMileage: VehicleMileage(
                id: "124",
                date: Date(),
                totalCost: 196.70,
                odometer: 1000,
                odometerDifference: 329,
                liters: 35.180,
                fuelCost: 5.59,
                calculatedMileage: 9.35,
                complete: true,
                vehicleId: "65f7489acdac2f577161d7f7"
            )
        )
        .brandFormListRow()
    }
    .listStyle(.insetGrouped)
    .brandScreen()
    .preferredColorScheme(.dark)
}
