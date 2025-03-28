//
//  ServiceListView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import SwiftUI
import TTProgressHUD
import RealmSwift

struct ServiceListView: View {
    
    @ObservedObject var viewModel: ViewModel
    @State private var isLoading = true
    @State private var isNewVehiclePresented = false

    @State private var presentedServices = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $presentedServices) {
            ScrollView {
                ForEach(viewModel.vehicleServices, id: \.id) { vehicleService in
                    NavigationLink(value: vehicleService) {
                        ServiceListItem(vehicleService: vehicleService)
                    }
                }
            }
            .navigationView(title: viewModel.selectedVehicle.name)
            .toolbar {
                Button(action: {}) {
                    NavigationLink(value: String()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .disabled(isLoading)
        .overlay(
            TTProgressHUD($isLoading, config: AutoCareApp.hudConfig)
        )
//        .task {
//            await viewModel.fetchData() // TODO: REFATORAR PARA ISSO
//            await viewModel.setup(app: app)
//        }
        .onChange(of: viewModel.state, { _, newState in
            isLoading = newState == .loading
            
            isNewVehiclePresented = newState == .newVehicle
        })
        .onChange(of: presentedServices) {
            oldValue,
            newValue in
            if newValue.isEmpty {
                Task {
//                    await viewModel.fetchVehicleServices()
                }
            }
        }
    }
}

#Preview {
    ServiceListView(
        viewModel: ServiceListView.ViewModel(
            selectedVehicle: VehicleData(
                id: "1",
                name: "Fiat Argo 2021",
                brand: "Fiat",
                model: "Argo",
                year: "2021",
                licensePlate: "AAA-1C34",
                odometer: 0,
                vehicleTypeId: "1",
                vehicleType: "Car",
                vehicleTypeEmoji: "🏎️"
            )
        )
    )
}
