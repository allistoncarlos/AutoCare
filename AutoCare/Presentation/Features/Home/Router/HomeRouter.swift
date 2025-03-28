//
//  HomeRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 09/11/24.
//

import SwiftUI
import SwiftData

@MainActor
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
    
    static func makeMileageListView(
        modelContext: ModelContext,
        selectedVehicle: VehicleData
    ) -> some View {
        return MileageListView(
            viewModel: MileageListView.ViewModel(
                modelContext: modelContext,
                selectedVehicle: selectedVehicle
            )
        )
    }
    
    static func makeServiceListView(selectedVehicle: VehicleData) -> some View {
        return ServiceListView(
            viewModel: ServiceListView.ViewModel(selectedVehicle: selectedVehicle)
        )
    }
}
