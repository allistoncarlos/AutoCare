//
//  MileageListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import Foundation
import RealmSwift
import Realm
import SwiftUI
import Combine
import SwiftData

extension MileageListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: MileageListState = .idle
        @Published var vehicleMileagesData = [VehicleMileageData]()
        @Published var selectedVehicle: VehicleData
        
        // MARK: - Properties
        var realm: Realm
        private var modelContext: ModelContext
        
        private var app: RealmSwift.App?
        private var cancellable = Set<AnyCancellable>()
        
        init(
            realm: Realm,
            modelContext: ModelContext,
            selectedVehicle: VehicleData
        ) {
            self.realm = realm
            self.modelContext = modelContext
            self.selectedVehicle = selectedVehicle
        }
        
        func setup(app: RealmSwift.App) async {
            self.app = app
            
            $state
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    switch state {
                    case let .successVehicleMileagesData(vehicleMileagesData):
                        self?.vehicleMileagesData = vehicleMileagesData
                    default:
                        break
                    }
                }.store(in: &cancellable)
            
            await fetchVehicleMileages()
        }
        
        // MARK: - Router
        func showEditVehicleView(
            realm: Realm,
            vehicleId: String?,
            isPresented: Binding<Bool>
        ) -> some View {
            return MileagesRouter.makeEditVehicleView(
                realm: realm,
                vehicleId: vehicleId,
                isPresented: isPresented
            )
        }
        
        func editMileageView(
            navigationPath: Binding<NavigationPath>,
            realm: Realm,
            userId: String,
            vehicleId: String,
            vehicleMileage: VehicleMileage? = nil
        ) -> some View {
            return MileagesRouter.makeEditMileageView(
                navigationPath: navigationPath,
                realm: realm,
                userId: userId,
                vehicleId: vehicleId,
                vehicleMileage: vehicleMileage
            )
        }
        
        func fetchVehicleMileages() async {
            state = .loading
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
