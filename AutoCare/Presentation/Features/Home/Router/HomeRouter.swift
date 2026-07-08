//
//  HomeRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 09/11/24.
//

import PulseUI
import SwiftUI

@MainActor
enum HomeRouter {
    static func makeEditVehicleView(
        vehicleId: String?,
        isPresented: Binding<Bool>
    ) -> some View {
        VehicleEditView(
            viewModel: VehicleEditView.ViewModel(vehicleId: vehicleId),
            isPresented: isPresented
        )
        .interactiveDismissDisabled()
    }

    static func makePulseUI() -> some View {
        NavigationView { ConsoleView() }
    }

    static func makeMileageListView(selectedVehicle: Vehicle) -> some View {
        MileageListView(
            viewModel: MileageListView.ViewModel(selectedVehicle: selectedVehicle)
        )
    }

    static func makeServiceListView(selectedVehicle: Vehicle) -> some View {
        ServiceListView(
            viewModel: ServiceListView.ViewModel(selectedVehicle: selectedVehicle)
        )
    }
}
