//
//  HomeView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 09/11/24.
//

import SwiftData
import SwiftUI
import TTProgressHUD

struct HomeView: View {
    @ObservedObject var viewModel: HomeView.ViewModel
    @State private var isLoading = false
    @State private var isNewVehiclePresented = false
    @State private var isPulseConsolePresented = false

    init(viewModel: HomeView.ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        TabView {
            if let selectedVehicle = viewModel.selectedVehicle {
                HomeRouter.makeMileageListView(
                    modelContext: viewModel.modelContext,
                    selectedVehicle: selectedVehicle
                )
                .tabItem {
                    Label("Dashboard", systemImage: "display")
                }

                HomeRouter.makeServiceListView(
                    modelContext: viewModel.modelContext,
                    selectedVehicle: selectedVehicle
                )
                .tabItem {
                    Label("Serviços", systemImage: "car.badge.gearshape")
                }
            }
        }
        .disabled(isLoading)
        .overlay(
            TTProgressHUD($isLoading, config: AutoCareApp.hudConfig)
        )
        .task {
            await viewModel.requestAuthorizationForNotifications()
            await viewModel.fetchData()
        }
        .onChange(of: isNewVehiclePresented) { _, newValue in
            if !newValue {
                Task { await viewModel.fetchData() }
            }
        }
        .onChange(of: viewModel.state) { _, newValue in
            isLoading = newValue == .loading
            isNewVehiclePresented = newValue == .newVehicle
        }
        .onShake {
            isPulseConsolePresented = true
        }
        .sheet(isPresented: $isNewVehiclePresented) {
            viewModel.showEditVehicleView(
                vehicleId: viewModel.selectedVehicle?.id,
                isPresented: $isNewVehiclePresented
            )
        }
        .sheet(isPresented: $isPulseConsolePresented) {
            viewModel.showPulseUI()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Vehicle.self, VehicleType.self, VehicleMileage.self, VehicleService.self,
        configurations: config
    )

    return HomeView(viewModel: HomeView.ViewModel(modelContext: container.mainContext))
}
