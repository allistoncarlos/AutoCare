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
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: MileageListState = .idle
        @Published var vehicleMileages = [VehicleMileage]()
        @Published var selectedVehicle: Vehicle

        private var modelContext: ModelContext
        private var cancellable = Set<AnyCancellable>()
        
        @Injected(\.vehicleMileageRepository) private var repository: VehicleMileageRepositoryProtocol
        
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
                vehicleId: vehicleId,
                vehicleMileage: vehicleMileage
            )
        }
        
        func fetchData(isConnected: Bool) async {
            if isConnected {
                await fetchRemoteData()
            } else {
                fetchLocalData()
            }
        }
        
        private func fetchRemoteData() async {
            if let id = selectedVehicle.id {
                state = .loading
                
                let result = await repository.fetchData(vehicleId: id)
                
                if let result {
                    state = .successVehicleMileages(result)
                    
                    self.syncData(result)
                } else {
                    state = .newVehicle
                }
            }
        }
        
        private func fetchLocalData() {
            do {
                state = .loading
                
                let descriptor = FetchDescriptor<VehicleMileage>(
                    sortBy: [SortDescriptor(\.date, order: .reverse)]
                )

                let result = try modelContext.fetch(descriptor)
                
                state = .successVehicleMileages(result)
            } catch {
                state = .newVehicle
            }
        }
        
        private func syncData(_ vehicleMileages: [VehicleMileage]) {
            do {
                try modelContext.delete(model: VehicleMileage.self)
                
                vehicleMileages.forEach { vehicleMileage in
                    vehicleMileage.synced = true
                    modelContext.insert(vehicleMileage)
                }
                
                try modelContext.save()
                
                self.fetchLocalData()
            } catch {
                print(error)
            }
        }
    }
}
