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
    final class ViewModel: ObservableObject {
        @Published private(set) var state: MileageListState = .idle
        @Published private(set) var vehicleMileages: [VehicleMileage] = []

        let selectedVehicle: Vehicle

        @Injected(\.vehicleMileageRepository) private var repository

        init(selectedVehicle: Vehicle) {
            self.selectedVehicle = selectedVehicle
        }

        func editMileageView(
            navigationPath: Binding<NavigationPath>,
            vehicleId: String,
            mileageClientId: String? = nil
        ) -> some View {
            MileagesRouter.makeEditMileageView(
                navigationPath: navigationPath,
                vehicleId: vehicleId,
                mileageClientId: mileageClientId
            )
        }

        func fetchData() async {
            state = .loading
            await fetchLocalData()
        }

        private func fetchLocalData() async {
            let vehicleId = selectedVehicle.referenceId

            vehicleMileages = await repository.fetchData(vehicleId: vehicleId) ?? []
            state = .successVehicleMileages(vehicleMileages)
        }
    }
}
