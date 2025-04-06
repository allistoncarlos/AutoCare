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

extension HomeView {
    final class ViewModel: ObservableObject, Sendable {
        let modelContext: ModelContext
        
        @Published var state: HomeState = .idle
        @Published var selectedVehicle: Vehicle?
        
        private var cancellable = Set<AnyCancellable>()
        private var networkConnectivity = NetworkConnectivity()
        
        @Injected(\.vehicleTypeRepository) private var vehicleTypeRepository: VehicleTypeRepositoryProtocol
        @Injected(\.vehicleRepository) private var repository: VehicleRepositoryProtocol
        @Injected(\.vehicleMileageRepository) private var vehicleMileageRepository: VehicleMileageRepositoryProtocol
        
        init(modelContext: ModelContext) {
            self.modelContext = modelContext
            
            $state
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    switch state {
                    case let .successVehicle(vehicles):
                        self?.selectedVehicle = vehicles.first
                        
                        // TODO: Aqui eu preciso verificar quando tiver o veículo padrão... Atualmente só tô pegando o primeiro
                        // TODO: SALVAR O ATRIBUTO ISDEFAULT NA ENTIDADE
                    default:
                        break
                    }
                }.store(in: &cancellable)
        }
        
        func showEditVehicleView(
            vehicleId: String?,
            isPresented: Binding<Bool>
        ) -> some View {
            return HomeRouter.makeEditVehicleView(
                modelContext: modelContext,
                vehicleId: vehicleId,
                isPresented: isPresented
            )
        }
        
        func showPulseUI() -> some View {
            return HomeRouter.makePulseUI()
        }
        
        func fetchData() async {
            if networkConnectivity.status != .connected { return }
            
            do {
//                state = .loading
                
                var vehicleTypes: [VehicleType] = []
                var vehicles: [Vehicle] = []
                var vehicleMileages: [VehicleMileage] = []
                
                await withTaskGroup(of: Void.self) { [weak self] group in
                    vehicleTypes = await self?.vehicleTypeRepository.fetchData() ?? []
                    
                    vehicles = await self?.repository.fetchData() ?? []
                }
                
                await withTaskGroup(of: Void.self) { [weak self] group in
                    for vehicle in vehicles {
                        if let id = vehicle.id {
                            group.addTask {
                                let vehicleMileagesByVehicle = await self?.vehicleMileageRepository.fetchData(vehicleId: id)
                                vehicleMileages.append(contentsOf: vehicleMileagesByVehicle ?? [])
                            }
                        }
                    }
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
                
                for index in 0...50 {
                    print(index)
                    try await SwiftDataManager.shared.importData(vehicleTypes)
                    try await SwiftDataManager.shared.importData(vehicles)
                    try await SwiftDataManager.shared.importData(vehicleMileages)
                }
                
                await MainActor.run {
                    state = vehicles.isEmpty ? .newVehicle : .successVehicle(vehicles)
                }
            } catch {
                print(error.localizedDescription)
                state = .newVehicle
            }
        }
    }
}
