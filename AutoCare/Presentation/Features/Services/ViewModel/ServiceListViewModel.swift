//
//  ServiceListViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Foundation
import SwiftUI
import Combine

extension ServiceListView {
    @MainActor
    class ViewModel: ObservableObject {
        @Published var state: ServiceListState = .idle
        @Published var vehicleServices = [VehicleService]()
        @Published var selectedVehicle: Vehicle
        
        private var cancellable = Set<AnyCancellable>()
        
        init(selectedVehicle: Vehicle) {
            self.selectedVehicle = selectedVehicle
        }
        
//        func setup(app: RealmSwift.App) async {
//            self.app = app
//            
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
//            await fetchVehicleServices()
//        }
        
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
        
//        func fetchVehicleServices() async {
//            state = .loading
//            
//            if let app, let user = app.currentUser {
//                let vehicleServices = try! await realm.objects(VehicleService.self)
//                    .where {
//                        // TODO: Colocar o vehicleId correto aqui
//                        $0.owner_id == user.id /*&&
//                        $0.vehicle_id == selectedVehicle.id*/
//                    }
//                    .subscribe(
//                        name: "vehicle-services",
//                        waitForSync: .onCreation
//                    )
//                
//                var vehicleServicesArray = Array(vehicleServices)
//                vehicleServicesArray = vehicleServicesArray.sorted(by: {
//                    $0.date.compare($1.date) == .orderedDescending
//                })
//                
//                state = .successVehicleServices(vehicleServicesArray)
//            }
//        }
    }
}
