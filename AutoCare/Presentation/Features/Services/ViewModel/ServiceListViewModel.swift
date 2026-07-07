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
        private let localStore: LocalDataStore
        let selectedVehicle: Vehicle
        private let networkConnectivity = NetworkConnectivity()

        @Injected(\.vehicleServiceRepository) private var repository

        init(modelContext: ModelContext, selectedVehicle: Vehicle) {
            self.modelContext = modelContext
            self.localStore = LocalDataStore(modelContext: modelContext)
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

            if networkConnectivity.status == .connected, let vehicleId = selectedVehicle.id {
                await fetchRemoteData(vehicleId: vehicleId)
            }

            fetchLocalData()
        }

        private func fetchRemoteData(vehicleId: String) async {
            guard let result = await repository.fetchData(vehicleId: vehicleId) else { return }

            do {
                let existing = try localStore.fetch(
                    where: #Predicate<VehicleService> { $0.vehicle_id == vehicleId }
                )
                existing.forEach { modelContext.delete($0) }

                result.forEach { service in
                    service.synced = true
                    modelContext.insert(service)
                }

                try localStore.save()
            } catch {
                print(error)
            }
        }

        private func fetchLocalData() {
            do {
                guard let vehicleId = selectedVehicle.id else {
                    state = .error
                    return
                }

                vehicleServices = try localStore.fetch(
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
