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

extension MileageListView.ViewModel {
    actor ViewModelState {
        let statePublisher = CurrentValueSubject<MileageListState, Never>(.idle)
        let selectedVehiclePublisher = PassthroughSubject<Vehicle, Never>()
        let vehicleMileagesPublisher = PassthroughSubject<[VehicleMileage], Never>()

        var cancellable = Set<AnyCancellable>()
        var networkConnectivity = NetworkConnectivity()

        func setState(_ newState: MileageListState) {
            statePublisher.send(newState)
        }

        func setVehicle(_ vehicle: Vehicle) {
            selectedVehiclePublisher.send(vehicle)
        }
        
        func setVehicleMileages(_ vehicleMileages: [VehicleMileage]) {
            vehicleMileagesPublisher.send(vehicleMileages)
        }
        
        func store(_ cancellable: AnyCancellable) {
            self.cancellable.insert(cancellable)
        }
    }
}

extension MileageListView {
    class ViewModel: ObservableObject {
        let modelContainer: ModelContainer
        
        let stateStore = ViewModelState()
        
        private let selectedVehicle: Vehicle

        init(
            modelContainer: ModelContainer,
            selectedVehicle: Vehicle
        ) {
            self.modelContainer = modelContainer
            self.selectedVehicle = selectedVehicle

            Task {
                let cancellable = await stateStore.statePublisher
                    .sink { [weak self] state in
                        switch state {
                        case let .successVehicleMileages(vehicleMileages):
                            Task {
                                await self?.stateStore.setVehicleMileages(vehicleMileages)
                            }
                        default:
                            break
                        }
                    }

                await stateStore.store(cancellable)
            }
        }

        @MainActor
        func editMileageView(
            navigationPath: Binding<NavigationPath>,
            vehicleId: String,
            vehicleMileage: VehicleMileage? = nil
        ) -> some View {
            return MileagesRouter.makeEditMileageView(
                navigationPath: navigationPath,
                modelContainer: modelContainer,
                vehicleId: vehicleId,
                vehicleMileage: vehicleMileage
            )
        }
        
        func fetchData() async {
            do {
                await stateStore.setState(.loading)
                
                let result: [VehicleMileage] = try await SwiftDataManager.shared.fetch(sortBy: [SortDescriptor(\VehicleMileage.date, order: .reverse)])
                
                await stateStore.setState(.successVehicleMileages(result))
                await self.stateStore.setVehicle(selectedVehicle)
            } catch {
                print(error.localizedDescription)
                await stateStore.setState(.error)
            }
        }
    }
}
