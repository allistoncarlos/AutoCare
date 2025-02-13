//
//  ServiceListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Foundation
import RealmSwift
import Realm
import SwiftUI
import Combine

extension ServiceListView {
    @MainActor
    class ViewModel: ObservableObject {
//        @Published var state: ServiceListState = .idle
//        @Published var vehicleServices = [VehicleService]()
//        @Published var selectedVehicle: Vehicle?
        
        // MARK: - Properties
        var realm: Realm? = nil
        
        private var app: RealmSwift.App?
        private var cancellable = Set<AnyCancellable>()
        
        func setup(app: RealmSwift.App) async {
            self.app = app
            
//            $state
//                .receive(on: RunLoop.main)
//                .sink { [weak self] state in
//                    switch state {
//                    case let .successVehicleServices(vehicleServices):
//                        self?.vehicleServices = vehicleServices
//                    default:
//                        break
//                    }
//                }.store(in: &cancellable)
//            
//            await fetchVehicles()
        }
        
//        // MARK: - Router
//        func showEditVehicleView(
//            realm: Realm,
//            vehicleId: ObjectId?,
//            isPresented: Binding<Bool>
//        ) -> some View {
//            return ServicesRouter.makeEditVehicleView(
//                realm: realm,
//                vehicleId: vehicleId,
//                isPresented: isPresented
//            )
//        }
//        
//        func editServiceView(
//            navigationPath: Binding<NavigationPath>,
//            realm: Realm,
//            userId: String,
//            vehicleId: ObjectId,
//            vehicleService: VehicleService? = nil
//        ) -> some View {
//            return ServicesRouter.makeEditServiceView(
//                navigationPath: navigationPath,
//                realm: realm,
//                userId: userId,
//                vehicleId: vehicleId,
//                vehicleService: vehicleService
//            )
//        }
//        
//        func fetchVehicleServices(
//            realm: Realm,
//            userId: String,
//            vehicleId: ObjectId
//        ) async {
//            let vehicleServices = try! await realm.objects(VehicleService.self)
//                .where {
//                    $0.owner_id == userId &&
//                    $0.vehicle_id == vehicleId
//                }
//                .subscribe(
//                    name: "vehicle-Services",
//                    waitForSync: .onCreation
//                )
//            
//            var vehicleServicesArray = Array(vehicleServices)
//            vehicleServicesArray = vehicleServicesArray.sorted(by: {
//                $0.date.compare($1.date) == .orderedDescending
//            })
//            
//            state = .successVehicleServices(vehicleServicesArray)
//        }
//        
//        private func fetchVehicles() async {
//            state = .loading
//            
//            if realm == nil {
//                do {
//                    self.realm = try await self.openRealm()
//                } catch {
//                    state = .error
//                }
//            }
//            
//            if let realm, let app, let user = app.currentUser {
//                let vehicles = try! await realm.objects(Vehicle.self)
//                    .where { $0.owner_id == user.id }
//                    .subscribe(
//                        name: "vehicle",
//                        waitForSync: .onCreation
//                    )
//                
//                _ = try! await realm.objects(VehicleType.self)
//                    .where { $0.enabled }
//                    .subscribe(
//                        name: "enabled-vehicle-types",
//                        waitForSync: .onCreation
//                    )
//                
//                if vehicles.isEmpty {
//                    state = .newVehicle
//                } else {
//                    // TODO: Aqui eu preciso verificar quando tiver o veículo padrão... Atualmente só tô pegando o primeiro
//                    
//                    if let vehicle = vehicles.first {
//                        self.selectedVehicle = vehicle
//                        
//                        await fetchVehicleServices(
//                            realm: realm,
//                            userId: user.id,
//                            vehicleId: vehicle._id
//                        )
//                    }
//                }
//            }
//        }
//        
//        private func openRealm() async throws -> Realm {
//            guard let app = app, let user = app.currentUser else {
//                throw AppError(_nsError: NSError())
//            }
//            
//            let config = user.flexibleSyncConfiguration()
//            let realm = try await Realm(configuration: config)
//            
//            return realm
//        }
    }
}
