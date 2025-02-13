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

extension MileageListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: MileageListState = .idle
        @Published var vehicleMileages = [VehicleMileage]()
        @Published var selectedVehicle: Vehicle
        
        // MARK: - Properties
        var realm: Realm
        
        private var app: RealmSwift.App?
        private var cancellable = Set<AnyCancellable>()
        
        init(realm: Realm, selectedVehicle: Vehicle) {
            self.realm = realm
            self.selectedVehicle = selectedVehicle
        }
        
        func setup(app: RealmSwift.App) async {
            self.app = app
            
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
            
            await fetchVehicleMileages()
        }
        
        // MARK: - Router
        func showEditVehicleView(
            realm: Realm,
            vehicleId: ObjectId?,
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
            vehicleId: ObjectId,
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
            
            if let app, let user = app.currentUser {
                let vehicleMileages = try! await realm.objects(VehicleMileage.self)
                    .where {
                        $0.owner_id == user.id &&
                        $0.vehicle_id == selectedVehicle._id
                    }
                    .subscribe(
                        name: "vehicle-mileages",
                        waitForSync: .onCreation
                    )
                
                var vehicleMileagesArray = Array(vehicleMileages)
                vehicleMileagesArray = vehicleMileagesArray.sorted(by: {
                    $0.date.compare($1.date) == .orderedDescending
                })
                
                state = .successVehicleMileages(vehicleMileagesArray)
            }
        }
    }
}
