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
        private let localStore: LocalDataStore
        let selectedVehicle: Vehicle
        private let networkConnectivity = NetworkConnectivity()

        @Injected(\.vehicleMileageRepository) private var repository

        init(modelContext: ModelContext, selectedVehicle: Vehicle) {
            self.modelContext = modelContext
            self.localStore = LocalDataStore(modelContext: modelContext)
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

            if networkConnectivity.status == .connected, let vehicleId = selectedVehicle.id {
                await fetchRemoteData(vehicleId: vehicleId)
            }

            fetchLocalData()
        }

        private func fetchRemoteData(vehicleId: String) async {
            guard let result = await repository.fetchData(vehicleId: vehicleId) else { return }

            do {
                let existing = try localStore.fetch(
                    where: #Predicate<VehicleMileage> { $0.vehicleId == vehicleId }
                )
                existing.forEach { modelContext.delete($0) }

                result.forEach { mileage in
                    mileage.synced = true
                    modelContext.insert(mileage)
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

                vehicleMileages = try localStore.fetch(
                    where: #Predicate<VehicleMileage> { $0.vehicleId == vehicleId },
                    sortBy: [SortDescriptor(\.date, order: .reverse)]
                )
                state = .successVehicleMileages(vehicleMileages)
            } catch {
                print(error.localizedDescription)
                state = .error
            }
        }
    }
}
