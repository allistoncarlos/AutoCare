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
    final class ViewModel: ObservableObject {
        @Published private(set) var state: ServiceListState = .idle
        @Published private(set) var vehicleServices: [VehicleService] = []

        let selectedVehicle: Vehicle

        @Injected(\.vehicleServiceRepository) private var repository

        init(selectedVehicle: Vehicle) {
            self.selectedVehicle = selectedVehicle
        }

        func editServiceView(
            navigationPath: Binding<NavigationPath>,
            vehicleId: String,
            serviceClientId: String? = nil
        ) -> some View {
            ServicesRouter.makeEditServiceView(
                navigationPath: navigationPath,
                vehicleId: vehicleId,
                serviceClientId: serviceClientId
            )
        }

        func fetchData() async {
            state = .loading
            await fetchLocalData()
        }

        func deleteService(_ vehicleService: VehicleService) async {
            await repository.delete(vehicleService: vehicleService)
            await fetchLocalData()
        }

        private func fetchLocalData() async {
            let vehicleId = selectedVehicle.referenceId

            vehicleServices = await repository.fetchData(vehicleId: vehicleId) ?? []
            state = .successVehicleServices(vehicleServices)
        }
    }
}
