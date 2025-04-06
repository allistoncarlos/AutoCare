//
//  MileageListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import Foundation
import SwiftUI
import Combine
import SwiftData
import Factory

extension MileageListView {
    class ViewModel: ObservableObject {
        @Published var state: MileageListState = .idle
        @Published var vehicleMileages = [VehicleMileage]()
        @Published var selectedVehicle: Vehicle

        private var modelContext: ModelContext
        private var cancellable = Set<AnyCancellable>()

        init(
            modelContext: ModelContext,
            selectedVehicle: Vehicle
        ) {
            self.modelContext = modelContext
            self.selectedVehicle = selectedVehicle
            
            $state
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    switch state {
                    case let .successVehicleMileages(vehicleMileages):
                        self?.vehicleMileages = vehicleMileages
                    default:
                        break
                    }
                }.store(in: &cancellable)
        }
        
        func editMileageView(
            navigationPath: Binding<NavigationPath>,
            vehicleId: String,
            vehicleMileage: VehicleMileage? = nil
        ) -> some View {
            return MileagesRouter.makeEditMileageView(
                navigationPath: navigationPath,
                modelContext: modelContext,
                vehicleId: vehicleId,
                vehicleMileage: vehicleMileage
            )
        }
        
        func fetchData() async {
            do {
                await MainActor.run { state = .loading }
                
                let result: [VehicleMileage] = try SwiftDataManager.shared.fetch(sortBy: [SortDescriptor(\VehicleMileage.date, order: .reverse)])
                
                await MainActor.run { state = .successVehicleMileages(result) }
            } catch {
                print(error.localizedDescription)
                state = .error
            }
        }
    }
}
