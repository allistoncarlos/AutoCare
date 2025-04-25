//
//  HomeViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Foundation
import Combine
import Factory
import SwiftData
import SwiftUI

extension HomeView.ViewModel {
    actor ViewModelState {
        let statePublisher = CurrentValueSubject<HomeState, Never>(.idle)
        let selectedVehiclePublisher = PassthroughSubject<Vehicle?, Never>()
        
        var cancellable = Set<AnyCancellable>()
        var networkConnectivity = NetworkConnectivity()
        
        @Injected(\.vehicleTypeRepository) var vehicleTypeRepository: VehicleTypeRepositoryProtocol
        @Injected(\.vehicleRepository) var repository: VehicleRepositoryProtocol
        @Injected(\.vehicleMileageRepository) var vehicleMileageRepository: VehicleMileageRepositoryProtocol

        func setState(_ newState: HomeState) {
            statePublisher.send(newState)
        }

        func setVehicle(_ vehicle: Vehicle?) {
            selectedVehiclePublisher.send(vehicle)
        }
        
        func store(_ cancellable: AnyCancellable) {
            self.cancellable.insert(cancellable)
        }
    }
}

extension HomeView {
    final class ViewModel: ObservableObject, Sendable {
        let modelContainer: ModelContainer
        
        let stateStore = ViewModelState()
        
        init(modelContainer: ModelContainer) {
            self.modelContainer = modelContainer
            
            Task {
                let cancellable = await stateStore.statePublisher
                    .sink { [weak self] state in
                        switch state {
                        case let .successVehicle(vehicles):
                            Task {
                                if await self?.stateStore.networkConnectivity.status != .connected && vehicles.isEmpty{
                                    await self?.stateStore.setState(.newVehicle)
                                } else {
                                    await self?.stateStore.setVehicle(vehicles.first)
                                }
                            }
                        default:
                            break
                        }
                    }

                await stateStore.store(cancellable)
            }
        }
        
        @MainActor
        func showEditVehicleView(
            vehicleId: String?,
            isPresented: Binding<Bool>
        ) -> some View {
            return HomeRouter.makeEditVehicleView(
                modelContainer: modelContainer,
                vehicleId: vehicleId,
                isPresented: isPresented
            )
        }
        
        func showPulseUI() -> some View {
            return HomeRouter.makePulseUI()
        }
        
        func fetchData() async {
            do {
                if await stateStore.networkConnectivity.status != .connected {
                    try await fetchLocal()
                }
                else {
                    try await fetchRemote()
                }
                
            } catch {
                print(error.localizedDescription)
                await stateStore.setState(.error)
            }
        }
        
        private func fetchLocal() async throws {
            await stateStore.setState(.loading)
            
            let result: [Vehicle] = try await SwiftDataManager.shared.fetch()
            
            await stateStore.setState(.successVehicle(result))
        }
        
        private func fetchRemote() async throws {
            var vehicleTypes: [VehicleType] = []
            var vehicles: [Vehicle] = []
            
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    vehicleTypes = await self.stateStore.vehicleTypeRepository.fetchData() ?? []
                }
                group.addTask {
                    vehicles = await self.stateStore.repository.fetchData() ?? []
                }
            }
            
            var vehicleMileages: [VehicleMileage] = await withTaskGroup(of: [VehicleMileage].self) { group in
                for vehicle in vehicles {
                    if let id = vehicle.id {
                        group.addTask {
                            return await self.stateStore.vehicleMileageRepository.fetchData(vehicleId: id) ?? []
                        }
                    }
                }
                
                var collected: [VehicleMileage] = []
                for await result in group {
                    collected.append(contentsOf: result)
                }
                return collected
            }
            
            vehicleTypes = vehicleTypes.map { vehicleType in
                vehicleType.synced = true
                return vehicleType
            }
            
            vehicles = vehicles.map { vehicle in
                vehicle.synced = true
                return vehicle
            }
            
            vehicleMileages = vehicleMileages.map { vehicleMileage in
                vehicleMileage.synced = true
                return vehicleMileage
            }
            
            await stateStore.setState(vehicles.isEmpty ? .newVehicle : .successVehicle(vehicles))
            
            try await SwiftDataManager.shared.importData(vehicleTypes)
            try await SwiftDataManager.shared.importData(vehicles)
            try await SwiftDataManager.shared.importData(vehicleMileages)
        }
    }
}
