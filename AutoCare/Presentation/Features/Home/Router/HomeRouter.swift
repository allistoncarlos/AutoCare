//
//  HomeRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 09/11/24.
//

import SwiftUI
import SwiftData
import PulseUI

enum HomeRouter {
    static func makeEditVehicleView(
        modelContext: ModelContext,
        vehicleId: String?,
        isPresented: Binding<Bool>
    ) -> some View {
        return VehicleEditView(
            viewModel: VehicleEditView.ViewModel(
                modelContext: modelContext,
                vehicleId: vehicleId
            ),
            isPresented: isPresented
        )
        .interactiveDismissDisabled()
    }
    
    static func makePulseUI() -> some View {
        return NavigationView { ConsoleView() }
    }
    
    static func makeMileageListView(
        modelContainer: ModelContainer,
        selectedVehicle: Vehicle
    ) -> some View {
        return MileageListView(
            viewModel: MileageListView.ViewModel(
                modelContainer: modelContainer,
                selectedVehicle: selectedVehicle
            )
        )
    }
    
    static func makeServiceListView(selectedVehicle: Vehicle) -> some View {
        return ServiceListView(
            viewModel: ServiceListView.ViewModel(selectedVehicle: selectedVehicle)
        )
    }
}
