//
//  MileageListView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import SwiftUI
import Realm
import TTProgressHUD
import RealmSwift

struct MileageListView: View {
    @EnvironmentObject var app: RLMApp
    
    @ObservedObject var viewModel: ViewModel
    @State private var isLoading = true
    @State private var isNewVehiclePresented = false
    @State private var selectedVehicleMileage: VehicleMileage? = nil
    
    @State private var presentedMileages = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $presentedMileages) {
            ScrollView {
                ForEach(viewModel.vehicleMileages, id: \.id) { vehicleMileage in
                    NavigationLink(value: vehicleMileage) {
                        MileageListItem(vehicleMileage: vehicleMileage)
                    }
                }
            }
            .navigationView(title: viewModel.selectedVehicle?.name ?? "")
            .toolbar {
                Button(action: {}) {
                    NavigationLink(value: String()) {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: String.self) { _ in
                if let user = app.currentUser,
                   let realm = viewModel.realm,
                   let vehicleId = viewModel.selectedVehicle?._id {
                    navigateToEditMileageView(realm: realm, user: user, vehicleId: vehicleId)
                }
            }
            .navigationDestination(for: VehicleMileage.self) { vehicleMileage in
                if let user = app.currentUser,
                   let realm = viewModel.realm,
                   let vehicleId = viewModel.selectedVehicle?._id {
                    navigateToEditMileageView(
                        realm: realm,
                        user: user,
                        vehicleId: vehicleId,
                        vehicleMileage: vehicleMileage
                    )
                }
            }
        }
        .disabled(isLoading)
        .overlay(
            TTProgressHUD($isLoading, config: AutoCareApp.hudConfig)
        )
        .task {
            await viewModel.setup(app: app)
        }
        .onChange(of: viewModel.state, { _, newState in
            isLoading = newState == .loading
            
            isNewVehiclePresented = newState == .newVehicle
        })
        .onChange(of: presentedMileages) {
            oldValue,
            newValue in
            if newValue.isEmpty {
                Task {
                    if let user = app.currentUser,
                       let realm = viewModel.realm,
                       let vehicleId = viewModel.selectedVehicle?._id {
                        await viewModel.fetchVehicleMileages(
                            realm:realm,
                            userId:user.id,
                            vehicleId:vehicleId
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $isNewVehiclePresented) {
            if app.currentUser != nil,
               let realm = viewModel.realm,
               let vehicleId = viewModel.selectedVehicle?._id
            {
                viewModel.showEditVehicleView(
                    realm: realm,
                    vehicleId: vehicleId,
                    isPresented: $isNewVehiclePresented
                )
            }
        }
    }
    
    func navigateToEditMileageView(
        realm: Realm,
        user: User,
        vehicleId: ObjectId,
        vehicleMileage: VehicleMileage? = nil
    ) -> some View {
        return viewModel.editMileageView(
            navigationPath: $presentedMileages,
            realm: realm,
            userId: user.id,
            vehicleId: vehicleId,
            vehicleMileage: vehicleMileage
        )
    }
}

#Preview {
    MileageListView(viewModel: MileageListView.ViewModel())
}
