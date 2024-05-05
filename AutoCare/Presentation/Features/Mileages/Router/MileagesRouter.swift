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
        let viewModel = MileageEditView.ViewModel(
            realm: realm,
            vehicleMileage: vehicleMileage,
            vehicleId: vehicleId
        )

        return MileageEditView(
            viewModel: viewModel,
            navigationPath: navigationPath
        )
    }

    static func goBackToMileages(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }
}
