//
//  MileageListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import Combine
import Factory
import Foundation
import SwiftData
import SwiftUI

extension MileageListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published private(set) var state: MileageListState = .idle
        @Published private(set) var vehicleMileages: [VehicleMileage] = []

        let modelContext: ModelContext
        let selectedVehicle: Vehicle

        @Injected(\.vehicleMileageRepository) private var repository

        init(modelContext: ModelContext, selectedVehicle: Vehicle) {
            self.modelContext = modelContext
            self.selectedVehicle = selectedVehicle
        }

        func editMileageView(
            navigationPath: Binding<NavigationPath>,
            vehicleId: String,
            vehicleMileage: VehicleMileage? = nil
        ) -> some View {
            MileagesRouter.makeEditMileageView(
                navigationPath: navigationPath,
                modelContext: modelContext,
                vehicleId: vehicleId,
                vehicleMileage: vehicleMileage
            )
        }

        func fetchData() async {
            state = .loading

            guard let vehicleId = selectedVehicle.id else {
                state = .error
                return
            }

            guard let result = await repository.fetchData(vehicleId: vehicleId) else {
                state = .error
                return
            }

            vehicleMileages = result
            state = .successVehicleMileages(result)
        }
    }
}
