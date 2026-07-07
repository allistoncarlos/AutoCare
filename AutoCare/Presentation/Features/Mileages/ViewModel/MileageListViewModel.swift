//
//  MileageListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import Combine
import Factory
import Foundation
import SwiftUI

extension MileageListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published private(set) var state: MileageListState = .idle
        @Published private(set) var vehicleMileages: [VehicleMileage] = []

        let selectedVehicle: Vehicle
        private let networkConnectivity = NetworkConnectivity()

        @Injected(\.swiftDataManager) private var swiftDataManager
        @Injected(\.vehicleMileageRepository) private var repository

        init(selectedVehicle: Vehicle) {
            self.selectedVehicle = selectedVehicle
        }

        func editMileageView(
            navigationPath: Binding<NavigationPath>,
            vehicleId: String,
            vehicleMileage: VehicleMileage? = nil
        ) -> some View {
            MileagesRouter.makeEditMileageView(
                navigationPath: navigationPath,
                vehicleId: vehicleId,
                vehicleMileage: vehicleMileage
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
                    where: #Predicate<VehicleMileage> { $0.vehicleId == vehicleId }
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

                vehicleMileages = try await swiftDataManager.fetch(
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
