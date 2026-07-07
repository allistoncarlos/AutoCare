//
//  VehicleListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 17/03/24.
//

import Combine
import Factory
import FormValidator
import Foundation

extension VehicleListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: VehicleListState = .idle
        @Published var vehicles = [Vehicle]()
        @Published var vehiclesData = [Vehicle]()

        private var cancellable = Set<AnyCancellable>()

        @Injected(\.swiftDataManager) private var swiftDataManager

        init() {
            $state
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    switch state {
                    case let .successVehicles(vehicles):
                        self?.vehicles = vehicles
                    default:
                        break
                    }
                }.store(in: &cancellable)
        }

        func fetchVehicles() async {
            state = .loading

            await fetchVehiclesData()

            state = .successVehicles(Array(vehicles))
        }

        func fetchVehiclesData() async {
            do {
                vehiclesData = try await swiftDataManager.fetch(sortBy: [SortDescriptor(\.name)])
            } catch {
                print("Fetch failed")
            }
        }
    }
}
