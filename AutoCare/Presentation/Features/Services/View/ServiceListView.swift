//
//  ServiceListView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import SwiftUI

import SwiftUI
import Realm
import TTProgressHUD
import RealmSwift

struct ServiceListView: View {
    @EnvironmentObject var app: RLMApp
    
    @ObservedObject var viewModel: ViewModel
    @State private var isLoading = true
    @State private var selectedVehicleService: VehicleService? = nil

    @State private var presentedServices = NavigationPath()
    
    var body: some View {
        Text("Hello, world!")
//        NavigationStack(path: $presentedServices) {
//            ScrollView {
//                ForEach(viewModel.vehicleServices, id: \.id) { vehicleService in
//                    NavigationLink(value: vehicleService) {
//                        ServiceListItem(vehicleService: vehicleService)
//                    }
//                }
//            }
//            .navigationView(title: viewModel.selectedVehicle?.name ?? "")
//            .toolbar {
//                Button(action: {}) {
//                    NavigationLink(value: String()) {
//                        Image(systemName: "plus")
//                    }
//                }
//            }
//            .navigationDestination(for: String.self) { _ in
//                if let user = app.currentUser,
//                   let realm = viewModel.realm,
//                   let vehicleId = viewModel.selectedVehicle?._id {
//                    navigateToEditServiceView(realm: realm, user: user, vehicleId: vehicleId)
//                }
//            }
//            .navigationDestination(for: VehicleService.self) { vehicleService in
//                if let user = app.currentUser,
//                   let realm = viewModel.realm,
//                   let vehicleId = viewModel.selectedVehicle?._id {
//                    navigateToEditServiceView(
//                        realm: realm,
//                        user: user,
//                        vehicleId: vehicleId,
//                        vehicleService: vehicleService
//                    )
//                }
//            }
//        }
//        .disabled(isLoading)
//        .overlay(
//            TTProgressHUD($isLoading, config: AutoCareApp.hudConfig)
//        )
//        .task {
//            await viewModel.setup(app: app)
//        }
//        .onChange(of: viewModel.state, { _, newState in
//            isLoading = newState == .loading
//            
//            isNewVehiclePresented = newState == .newVehicle
//        })
//        .onChange(of: presentedServices) {
//            oldValue,
//            newValue in
//            if newValue.isEmpty {
//                Task {
//                    if let user = app.currentUser,
//                       let realm = viewModel.realm,
//                       let vehicleId = viewModel.selectedVehicle?._id {
//                        await viewModel.fetchVehicleServices(
//                            realm:realm,
//                            userId:user.id,
//                            vehicleId:vehicleId
//                        )
//                    }
//                }
//            }
//        }
//        .sheet(isPresented: $isNewVehiclePresented) {
//            if app.currentUser != nil,
//               let realm = viewModel.realm,
//               let vehicleId = viewModel.selectedVehicle?._id
//            {
//                viewModel.showEditVehicleView(
//                    realm: realm,
//                    vehicleId: vehicleId,
//                    isPresented: $isNewVehiclePresented
//                )
//            }
//        }
    }
    
//    func navigateToEditServiceView(
//        realm: Realm,
//        user: User,
//        vehicleId: ObjectId,
//        vehicleService: VehicleService? = nil
//    ) -> some View {
//        return viewModel.editServiceView(
//            navigationPath: $presentedServices,
//            realm: realm,
//            userId: user.id,
//            vehicleId: vehicleId,
//            vehicleService: vehicleService
//        )
//    }
}

#Preview {
    ServiceListView(
        viewModel: ServiceListView.ViewModel(
            realm: try! Realm(),
            selectedVehicle: Vehicle(
                name: "Fiat Argo 2021",
                brand: "Fiat",
                model: "Argo",
                year: "2021",
                licensePlate: "AAA-1C34",
                odometer: 0,
                owner_id: "11234",
                vehicleType: VehicleType(name: "Car")
            )
        )
    )
}
