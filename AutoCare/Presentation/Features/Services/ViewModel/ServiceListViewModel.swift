//
//  ServiceListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Foundation
import SwiftUI
import Combine
import SwiftData
import Factory

extension ServiceListView.ViewModel {
    actor ViewModelState {
        let statePublisher = CurrentValueSubject<ServiceListState, Never>(.idle)
        let selectedVehiclePublisher = PassthroughSubject<Vehicle, Never>()
        let vehicleServicesPublisher = PassthroughSubject<[VehicleService], Never>()

        var cancellable = Set<AnyCancellable>()
        var networkConnectivity = NetworkConnectivity()

        func setState(_ newState: ServiceListState) {
            statePublisher.send(newState)
        }

        func setVehicle(_ vehicle: Vehicle) {
            selectedVehiclePublisher.send(vehicle)
        }
        
        func setVehicleServices(_ vehicleServices: [VehicleService]) {
            vehicleServicesPublisher.send(vehicleServices)
        }
        
        func store(_ cancellable: AnyCancellable) {
            self.cancellable.insert(cancellable)
        }
    }
}

extension ServiceListView {
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
                        case let .successVehicleServices(vehicleServices):
                            Task {
                                await self?.stateStore.setVehicleServices(vehicleServices)
                            }
                        default:
                            break
                        }
                    }

                await stateStore.store(cancellable)
            }
        }

        @MainActor
        func editServiceView(
            navigationPath: Binding<NavigationPath>,
            vehicleId: String,
            vehicleService: VehicleService? = nil
        ) -> some View {
            return ServicesRouter.makeEditServiceView(
                navigationPath: navigationPath,
                modelContainer: modelContainer,
                vehicleId: vehicleId,
                vehicleService: vehicleService
            )
        }
        
        func fetchData() async {
            do {
                await stateStore.setState(.loading)
                
                let result: [VehicleService] = try await SwiftDataManager.shared.fetch(sortBy: [SortDescriptor(\VehicleService.date, order: .reverse)])
                
                await stateStore.setState(.successVehicleServices(result))
                await self.stateStore.setVehicle(selectedVehicle)
            } catch {
                print(error.localizedDescription)
                await stateStore.setState(.error)
            }
        }
    }
}
