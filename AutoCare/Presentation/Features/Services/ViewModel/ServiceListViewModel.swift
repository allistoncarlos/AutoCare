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

        let selectedVehicle: Vehicle

        @Injected(\.vehicleServiceRepository) private var repository

        init(selectedVehicle: Vehicle) {
            self.selectedVehicle = selectedVehicle
        }

        func editServiceView(
            navigationPath: Binding<NavigationPath>,
            vehicleId: String,
            vehicleService: VehicleService? = nil
        ) -> some View {
            ServicesRouter.makeEditServiceView(
                navigationPath: navigationPath,
                vehicleId: vehicleId,
                vehicleService: vehicleService
            )
        }

        func fetchData() async {
            state = .loading
            await fetchLocalData()
        }

        private func fetchLocalData() async {
            do {
                guard let vehicleId = selectedVehicle.id else {
                    state = .error
                    return
                }

                vehicleServices = try await repository.fetchData(vehicleId: vehicleId) ?? []
                state = .successVehicleServices(vehicleServices)
            } catch {
                print(error.localizedDescription)
                state = .error
            }
        }
    }
}
