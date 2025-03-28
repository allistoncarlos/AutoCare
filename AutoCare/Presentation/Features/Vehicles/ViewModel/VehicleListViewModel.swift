//
//  VehicleListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 17/03/24.
//

import Foundation
import Combine
import FormValidator
import SwiftData

extension VehicleListView {
    @MainActor
    class ViewModel: ObservableObject {
        // MARK: - Published properties
        @Published var state: VehicleListState = .idle
        @Published var vehicles = [Vehicle]()
        @Published var vehiclesData = [Vehicle]()
        
        // MARK: - Properties
        private var cancellable = Set<AnyCancellable>()
        private var modelContext: ModelContext
        
        // MARK: - Init
        init(modelContext: ModelContext) {
            self.modelContext = modelContext
            
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
        
        // MARK: - Func
        func fetchVehicles() async {
            state = .loading
            
            self.fetchVehiclesData()
            
            // TODO: REMOVE REALM VEHICLES AND REPLACE FOR VEHICLE FROM API
//            let vehicles = Array(realm.objects(Vehicle.self))
//
//            vehicles.forEach { vehicle in
//                let vehicleId = "\(vehicle._id)"
//                
//                let vehicleData = Vehicle(
//                    id: vehicleId,
//                    name: vehicle.name,
//                    brand: vehicle.brand,
//                    model: vehicle.model,
//                    year: vehicle.year,
//                    licensePlate: vehicle.licensePlate,
//                    odometer: vehicle.odometer
//                )
//                
//                if vehiclesData.count == 0 {
//                    modelContext.insert(vehicleData)
//                }
//            }
            
            state = .successVehicles(Array(vehicles))
        }
        
        func fetchVehiclesData() {
            do {
                let descriptor = FetchDescriptor<Vehicle>(sortBy: [SortDescriptor(\.name)])
                self.vehiclesData = try modelContext.fetch(descriptor)
            } catch {
                print("Fetch failed")
            }
        }
    }
}
