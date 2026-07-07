//
//  ServiceListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Combine
import Factory
import Foundation
import SwiftUI

extension ServiceListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published private(set) var state: ServiceListState = .idle
        @Published private(set) var vehicleServices: [VehicleService] = []

        let selectedVehicle: Vehicle
        private let networkConnectivity = NetworkConnectivity()

        @Injected(\.swiftDataManager) private var swiftDataManager
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

            if networkConnectivity.status == .connected, let vehicleId = selectedVehicle.id {
                await fetchRemoteData(vehicleId: vehicleId)
            }

            await fetchLocalData()
        }

        private func fetchRemoteData(vehicleId: String) async {
            guard let result = await repository.fetchData(vehicleId: vehicleId) else { return }

            do {
                try await swiftDataManager.replaceAll(
                    result,
                    where: #Predicate<VehicleService> { $0.vehicle_id == vehicleId }
                )
            } catch {
                print(error)
            }
        }

        private func fetchLocalData() async {
            do {
                guard let vehicleId = selectedVehicle.id else {
                    state = .error
                    return
                }

                vehicleServices = try await swiftDataManager.fetch(
                    where: #Predicate<VehicleService> { $0.vehicle_id == vehicleId },
                    sortBy: [SortDescriptor(\.date, order: .reverse)]
                )
                state = .successVehicleServices(vehicleServices)
            } catch {
                print(error.localizedDescription)
                state = .error
            }
        }
    }
}
