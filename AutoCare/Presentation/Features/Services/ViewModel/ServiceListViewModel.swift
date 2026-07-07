//
//  ServiceListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Combine
import Factory
import Foundation
import SwiftData
import SwiftUI

extension ServiceListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published private(set) var state: ServiceListState = .idle
        @Published private(set) var vehicleServices: [VehicleService] = []

        let modelContext: ModelContext
        let selectedVehicle: Vehicle

        @Injected(\.vehicleServiceRepository) private var repository

        init(modelContext: ModelContext, selectedVehicle: Vehicle) {
            self.modelContext = modelContext
            self.selectedVehicle = selectedVehicle
        }

        func editServiceView(
            navigationPath: Binding<NavigationPath>,
            vehicleId: String,
            vehicleService: VehicleService? = nil
        ) -> some View {
            ServicesRouter.makeEditServiceView(
                navigationPath: navigationPath,
                modelContext: modelContext,
                vehicleId: vehicleId,
                vehicleService: vehicleService
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

            vehicleServices = result
            state = .successVehicleServices(result)
        }
    }
}
