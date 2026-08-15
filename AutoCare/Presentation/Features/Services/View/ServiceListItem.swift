//
//  ServiceListItem.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import SwiftUI

struct ServiceListItem: View {
    var vehicleService: VehicleService

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
                Image(systemName: vehicleService.type.systemImage)
                    .font(.subheadline)
                    .foregroundStyle(BrandTheme.Colors.violetSoft)

                Text(vehicleService.type.description)
                    .font(.body)
                    .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))
            }

            Text("\(vehicleService.subtype.description) · \(vehicleService.date.toFormattedString(dateFormat: AutoCareApp.dateFormat))")
                .font(.subheadline)
                .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
        }
    }

    private var trailingColumn: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if let totalCost = vehicleService.totalCost.toCurrencyString() {
                Text(totalCost)
                    .font(.body)
                    .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))
            }

            Text("\(vehicleService.odometer) km")
                .font(.subheadline)
                .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
        }
    }
}

#Preview {
    List {
        ServiceListItem(
            vehicleService: VehicleService(
                id: "1",
                date: Date(),
                odometer: 1234,
                type: .wheelsAndTyres,
                subtype: .calibrate,
                totalCost: 50,
                comment: "Comentário",
                vehicle_id: "65f7489acdac2f573161d7f7"
            )
        )
        .brandFormListRow()
    }
    .listStyle(.insetGrouped)
    .brandScreen()
    .preferredColorScheme(.dark)
}
