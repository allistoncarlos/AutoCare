//
//  HomeView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 09/11/24.
//

import SwiftUI
import TTProgressHUD

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject var viewModel: HomeView.ViewModel
    @State private var isLoading = true
    @State private var isNewVehiclePresented = false
    @State private var isPulseConsolePresented = false
    @State private var selectedVehicleMileage: VehicleMileage? = nil

    @State private var presentedMileages = NavigationPath()
    
    var body: some View {
        TabView {
            if let selectedVehicle = viewModel.selectedVehicle {
                HomeRouter.makeMileageListView(
                    modelContext: modelContext,
                    selectedVehicle: selectedVehicle
                )
                .tabItem {
                    Label("Dashboard", systemImage: "display")
                }
                
                HomeRouter.makeServiceListView(selectedVehicle: selectedVehicle)
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
            await viewModel.fetchData()
        }
        .onChange(of: viewModel.state, { _, newState in
            isLoading = newState == .loading
            
            isNewVehiclePresented = newState == .newVehicle
        })
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
    HomeView(viewModel: HomeView.ViewModel(modelContext: SwiftDataManager.shared.previewModelContext))
}
