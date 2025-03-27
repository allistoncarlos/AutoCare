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
import Factory

extension HomeView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: HomeState = .idle
        @Published var selectedVehicle: VehicleData?
        
        var realm: Realm? = nil
        
        private var app: RealmSwift.App?
        private var cancellable = Set<AnyCancellable>()
        
        @Injected(\.vehicleRepository) private var repository: VehicleRepositoryProtocol
        
        func setup(app: RealmSwift.App) async {
            self.app = app
            
            $state
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    switch state {
                    case let .successVehicleData(vehiclesData):
                        print(vehiclesData.debugDescription)
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
            
            let result = await repository.fetchData()

            if let result {
                state = .successVehicleData(result)
            } else {
                state = .error
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
