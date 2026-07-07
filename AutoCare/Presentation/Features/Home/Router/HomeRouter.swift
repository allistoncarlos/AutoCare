//
//  HomeRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 09/11/24.
//

import PulseUI
import SwiftData
import SwiftUI

enum HomeRouter {
    static func makeEditVehicleView(
        modelContext: ModelContext,
        vehicleId: String?,
        isPresented: Binding<Bool>
    ) -> some View {
        VehicleEditView(
            viewModel: VehicleEditView.ViewModel(
                modelContext: modelContext,
                vehicleId: vehicleId
            ),
            isPresented: isPresented
        )
        .interactiveDismissDisabled()
    }

    static func makePulseUI() -> some View {
        NavigationView { ConsoleView() }
    }

    static func makeMileageListView(
        modelContext: ModelContext,
        selectedVehicle: Vehicle
    ) -> some View {
        MileageListView(
            viewModel: MileageListView.ViewModel(
                modelContext: modelContext,
                selectedVehicle: selectedVehicle
            )
        )
    }

    static func makeServiceListView(
        modelContext: ModelContext,
        selectedVehicle: Vehicle
    ) -> some View {
        ServiceListView(
            viewModel: ServiceListView.ViewModel(
                modelContext: modelContext,
                selectedVehicle: selectedVehicle
            )
        )
    }
}
