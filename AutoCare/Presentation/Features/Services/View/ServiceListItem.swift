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
        BrandCard {
            HStack(alignment: .top, spacing: BrandTheme.Spacing.md) {
                Image(systemName: "car.badge.gearshape.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(BrandTheme.Colors.violetSoft)
                    .frame(width: 28)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: BrandTheme.Spacing.xs) {
                    Text(vehicleService.type.description)
                        .font(BrandTheme.Typography.body(15, weight: .semibold))
                        .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))

                    Text("\(vehicleService.subtype.description) · \(vehicleService.date.toFormattedString(dateFormat: AutoCareApp.dateFormat))")
                        .font(BrandTheme.Typography.caption(13))
                        .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)

                if let totalCost = vehicleService.totalCost.toCurrencyString() {
                    Text(totalCost)
                        .font(BrandTheme.Typography.heading(16))
                        .foregroundStyle(BrandTheme.Colors.textPrimary(colorScheme))
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
                    .padding(.top, 4)
            }
        }
    }
}

#Preview {
    ServiceListItem(
        vehicleService: VehicleService(
            id: "1",
            date: Date(),
            odometer: 1234,
            type: .wheelsAndTyres,
            subtype: .calibrate,
            totalCost: 0,
            comment: "Comentário",
            vehicle_id: "65f7489acdac2f573161d7f7"
        )
    )
    .padding()
    .brandBackground()
    .preferredColorScheme(.dark)
}
