//
//  VehicleListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 17/03/24.
//

import Foundation
import RealmSwift
import Realm
import Combine
import FormValidator
import SwiftData

extension VehicleListView {
    @MainActor
    class ViewModel: ObservableObject {
        // MARK: - Published properties
        @Published var state: VehicleListState = .idle
        @Published var vehicles = [VehicleData]()
        @Published var vehiclesData = [VehicleData]()
        
        // MARK: - Properties
        private var cancellable = Set<AnyCancellable>()
        private var realm: Realm
        private var modelContext: ModelContext
        
        // MARK: - Init
        init(realm: Realm, modelContext: ModelContext) {
            self.realm = realm
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
//            let vehicles = Array(realm.objects(VehicleData.self))
//
//            vehicles.forEach { vehicle in
//                let vehicleId = "\(vehicle._id)"
//                
//                let vehicleData = VehicleData(
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
                let descriptor = FetchDescriptor<VehicleData>(sortBy: [SortDescriptor(\.name)])
                self.vehiclesData = try modelContext.fetch(descriptor)
            } catch {
                print("Fetch failed")
            }
        }
    }
}
