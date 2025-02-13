//
//  HomeViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Foundation
import RealmSwift
import Realm
import Combine

extension HomeView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: HomeState = .idle
        @Published var selectedVehicle: Vehicle?
        
        var realm: Realm? = nil
        
        private var app: RealmSwift.App?
        private var cancellable = Set<AnyCancellable>()
        
        func setup(app: RealmSwift.App) async {
            self.app = app
            
            $state
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    switch state {
                    case let .successVehicle(vehicles):
                        // TODO: Aqui eu preciso verificar quando tiver o veículo padrão... Atualmente só tô pegando o primeiro
                        self?.selectedVehicle = vehicles.first
                    default:
                        break
                    }
                }.store(in: &cancellable)
            
            await fetchVehicles()
        }
        
        private func fetchVehicles() async {
            state = .loading
            
            if realm == nil {
                do {
                    self.realm = try await self.openRealm()
                } catch {
                    state = .error
                }
            }
            
            if let realm, let app, let user = app.currentUser {
                let vehicles = try! await realm.objects(Vehicle.self)
                    .where { $0.owner_id == user.id }
                    .subscribe(
                        name: "vehicle",
                        waitForSync: .onCreation
                    )
                
                _ = try! await realm.objects(VehicleType.self)
                    .where { $0.enabled }
                    .subscribe(
                        name: "enabled-vehicle-types",
                        waitForSync: .onCreation
                    )
                
                if vehicles.isEmpty {
                    state = .newVehicle
                } else {
                    state = .successVehicle(Array(vehicles))
                }
            }
        }
        
        private func openRealm() async throws -> Realm {
            guard let app = app, let user = app.currentUser else {
                throw AppError(_nsError: NSError())
            }
            
            let config = user.flexibleSyncConfiguration()
            let realm = try await Realm(configuration: config)
            
            return realm
        }
    }
}
