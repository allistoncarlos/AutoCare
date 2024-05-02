//
//  MileagesRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 17/03/24.
//

import Foundation
import SwiftUI
import RealmSwift

@MainActor
enum MileagesRouter {
    static func makeEditVehicleView(
        realm: Realm,
        vehicleId: ObjectId?,
        isPresented: Binding<Bool>
    ) -> some View {
        return VehicleEditView(
            viewModel: VehicleEditView.ViewModel(
                vehicleId: vehicleId,
                realm: realm
            ),
            isPresented: isPresented
        )
        .interactiveDismissDisabled()
    }
    
    static func makeEditMileageView(
        navigationPath: Binding<NavigationPath>,
        realm: Realm,
        userId: String,
        vehicleId: ObjectId,
        vehicleMileage: VehicleMileage?
    ) -> some View {
        let emptyVehicleMileage = VehicleMileage(
            date: Date(),
            totalCost: 0,
            odometer: 0,
            odometerDifference: 0,
            liters: 0,
            fuelCost: 0,
            calculatedMileage: 0,
            complete: true,
            owner_id: userId,
            vehicle_id: vehicleId
        )
        
        let viewModel = MileageEditView.ViewModel(vehicleMileage: vehicleMileage ?? emptyVehicleMileage)

        return MileageEditView(
            viewModel: viewModel,
            navigationPath: navigationPath
        )
    }

    static func goBackToMileages(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }
}
