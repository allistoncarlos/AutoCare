//
//  MileageListItem.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 19/03/24.
//

import SwiftUI

struct MileageListItem: View {
    var vehicleMileage: VehicleMileage
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(vehicleMileage.date.toFormattedString(dateFormat: AutoCareApp.dateFormat))")
                        .font(.headline)

                    if let liters = vehicleMileage.liters
                        .toLeadingZerosString(decimalPlaces: 3) {
                        Text("\(liters) Litros")
                            .font(.title)
                    }
                    
                    if let calculatedMileage = vehicleMileage.calculatedMileage.toLeadingZerosString(decimalPlaces: 3) {
                        Text("\(calculatedMileage) km/L")
                            .font(.callout)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                
                VStack(alignment: .trailing) {
                    Text("\(vehicleMileage.odometerDifference) km")
                        .font(.subheadline)
                    
                    if let totalCost = vehicleMileage.totalCost.toCurrencyString() {
                        Text(totalCost)
                            .font(.title)
                    }
                    
                    if let fuelCost = vehicleMileage.fuelCost.toCurrencyString() {
                        Text(fuelCost)
                            .font(.callout)
                    }
                }
                
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .foregroundStyle(.foreground)
        }
        .padding()
    }
}

#Preview {
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
}
