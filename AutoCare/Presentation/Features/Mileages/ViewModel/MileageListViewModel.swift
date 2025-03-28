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

extension MileageListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: MileageListState = .idle
//        @Published var vehicleMileages = [VehicleMileage]()
        @Published var vehicleMileagesData = [VehicleMileageData]()
        @Published var selectedVehicle: VehicleData
        
        // MARK: - Properties
        private var modelContext: ModelContext
        
        private var cancellable = Set<AnyCancellable>()
        
        init(
            modelContext: ModelContext,
            selectedVehicle: VehicleData
        ) {
            self.modelContext = modelContext
            self.selectedVehicle = selectedVehicle
        }
        
//        func setup(app: RealmSwift.App) async {
//            self.app = app
//            
//            $state
//                .receive(on: RunLoop.main)
//                .sink { [weak self] state in
//                    switch state {
//                    case let .successVehicleMileagesData(vehicleMileagesData):
//                        self?.vehicleMileagesData = vehicleMileagesData
//                    default:
//                        break
//                    }
//                }.store(in: &cancellable)
//            
//            await fetchVehicleMileages()
//        }
        
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
        
        func fetchVehicleMileages() async {
            state = .loading
            
//            if let app, let user = app.currentUser {
//                let vehicleMileages = try! await realm.objects(VehicleMileage.self)
//                    .where {
//                        $0.owner_id == user.id &&
//                        $0.vehicle_id == selectedVehicle.id
//                    }
//                    .subscribe(
//                        name: "vehicle-mileages",
//                        waitForSync: .onCreation
//                    )
//                
//                var vehicleMileagesArray = Array(vehicleMileages)
//                vehicleMileagesArray = vehicleMileagesArray.sorted(by: {
//                    $0.date.compare($1.date) == .orderedDescending
//                })
//                
//                self.syncSwiftData(vehicleMileagesArray)
//                
//                state = .successVehicleMileages(vehicleMileagesArray)
//            }
        }
        
        func syncSwiftData(_ vehicleMileages: [VehicleMileage]) {
            do {
                try modelContext.delete(model: VehicleMileageData.self)
                
                vehicleMileages.forEach { vehicleMileage in
                    let vehicleMileageData = vehicleMileage.mapToModel()
                    
                    modelContext.insert(vehicleMileageData)
                }
                
                self.fetchVehicleMileagesData()
            } catch {
                print(error)
            }
        }
        
        func fetchVehicleMileagesData() {
            do {
                state = .loading
                
                let descriptor = FetchDescriptor<VehicleMileageData>(
                    sortBy: [SortDescriptor(\.date, order: .reverse)]
                )

                let vehicleMileagesData = try modelContext.fetch(descriptor)
                
                state = .successVehicleMileagesData(vehicleMileagesData)
            } catch {
                print("Fetch failed")
            }
        }
    }
}
