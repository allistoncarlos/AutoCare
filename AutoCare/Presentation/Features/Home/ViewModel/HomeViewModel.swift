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
    @MainActor
    class ViewModel: ObservableObject {
        private var modelContext: ModelContext
        
        @Published var state: HomeState = .idle
        @Published var selectedVehicle: Vehicle?
        
        private var cancellable = Set<AnyCancellable>()
        
        @Injected(\.vehicleRepository) private var repository: VehicleRepositoryProtocol
        
        init(modelContext: ModelContext) {
            self.modelContext = modelContext
            
            $state
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    switch state {
                    case let .successVehicle(vehicles):
                        self?.selectedVehicle = vehicles.first
                        
                        // TODO: Aqui eu preciso verificar quando tiver o veículo padrão... Atualmente só tô pegando o primeiro
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
        
//        func setup(app: RealmSwift.App) async {
//            self.app = app
//            
//            $state
//                .receive(on: RunLoop.main)
//                .sink { [weak self] state in
//                    switch state {
//                    case let .successVehicle(vehiclesData):
//                        print(vehiclesData.debugDescription)
//                    case let .successVehicle(vehicles):
//                        // TODO: Aqui eu preciso verificar quando tiver o veículo padrão... Atualmente só tô pegando o primeiro
//                        self?.selectedVehicle = vehicles.first
//                    default:
//                        break
//                    }
//                }.store(in: &cancellable)
//            
//            await fetchVehicles()
//        }
        
//        private func fetchVehicles() async {
//            state = .loading
//            
//            let result = await repository.fetchData()
//
//            if vehicles.isEmpty {
//                state = .newVehicle
//            } else {
//                state = .successVehicle(Array(vehicles))
//            }
//        }
        func fetchData(isConnected: Bool) async {
            if isConnected {
                await fetchRemoteData()
            } else {
                fetchLocalData()
            }
        }
        
        private func fetchRemoteData() async {
            state = .loading

            let result = await repository.fetchData()

            if let result {
                state = .successVehicle(result)
                
                self.syncData(result)
            } else {
                state = .newVehicle
            }
        }
        
        private func fetchLocalData() {
            do {
                state = .loading
                
                let descriptor = FetchDescriptor<Vehicle>(
                    sortBy: [SortDescriptor(\.name)]
                )

                let result = try modelContext.fetch(descriptor)
                
                state = result.isEmpty ? .newVehicle : .successVehicle(result)
            } catch {
                state = .newVehicle
            }
        }
        
        private func syncData(_ vehicles: [Vehicle]) {
            do {
                try modelContext.delete(model: Vehicle.self)
                
                vehicles.forEach { vehicle in
//                    vehicle.synced = true
                    modelContext.insert(vehicle)
                }
                
                try modelContext.save()
                
                self.fetchLocalData()
            } catch {
                print(error)
            }
        }
    }
}
