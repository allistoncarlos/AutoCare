//
//  MileageListItem.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 19/03/24.
//

import SwiftUI
import RealmSwift

struct MileageListItem: View {
    var vehicleMileage: VehicleMileage
    
    var body: some View {
        VStack {
            Text("\(vehicleMileage.date.toFormattedString(dateFormat: AutoCareApp.dateFormat))")
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(vehicleMileage.liters) litros")
                    Text("\(vehicleMileage.calculatedMileage) km/L")
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .topLeading)
                
                VStack(alignment: .trailing) {
                    Text("\(vehicleMileage.totalCost)")
                    Text("\(vehicleMileage.fuelCost)")
                }
                
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .padding()
    }
}

#Preview {
    MileageListItem(
        vehicleMileage: VehicleMileage(
            date: Date(),
            totalCost: 205.36,
            odometer: 12450,
            liters: 37.123,
            fuelCost: 5.97,
            calculatedMileage: 10.35,
            complete: true,
            owner_id: "1",
            vehicle_id: try! ObjectId(string: "12345")
        )
    )
}
