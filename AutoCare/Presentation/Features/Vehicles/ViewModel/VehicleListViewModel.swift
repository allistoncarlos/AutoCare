//
//  VehicleListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 17/03/24.
//

import Combine
import Factory
import Foundation
import SwiftData
import SwiftUI

extension VehicleListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: VehicleListState = .idle
        @Published var vehicles = [Vehicle]()

        @Injected(\.vehicleRepository) private var repository

        init(modelContext: ModelContext) {}

        func fetchVehicles() async {
            state = .loading

            guard let result = await repository.fetchData() else {
                state = .error
                return
            }

            vehicles = result
            state = .successVehicles(result)
        }
    }
}
