//
//  ServiceListItem.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import SwiftUI

import SwiftUI

struct ServiceListItem: View {
    var vehicleService: VehicleService
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(vehicleService.type.description)
                    .foregroundColor(.primary)
                    .font(.headline)
            
                Label(
                    "\(vehicleService.subtype.description) (\(vehicleService.date.toFormattedString(dateFormat: AutoCareApp.dateFormat)))",
                    systemImage: "car.badge.gearshape.fill"
                )
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)

            if let totalCost = vehicleService.totalCost.toCurrencyString() {
                Text(totalCost)
                    .foregroundColor(.primary)
                    .font(.headline)
            }
        }
        .padding()
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
}
