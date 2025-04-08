//
//  HomeView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 09/11/24.
//

import SwiftUI
import TTProgressHUD
import SwiftData

struct HomeView: View {
    @ObservedObject var viewModel: HomeView.ViewModel
    @State private var isLoading = false
    @State private var isNewVehiclePresented = false
    @State private var isPulseConsolePresented = false
    @State private var selectedVehicle: Vehicle? = nil
    @State private var selectedVehicleMileage: VehicleMileage? = nil

    @State private var presentedMileages = NavigationPath()
    
    @State private var stateStore = HomeView.ViewModel.ViewModelState()
    @State private var state: HomeState = .idle
    
    init(viewModel: HomeView.ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        TabView {
            if let selectedVehicle = selectedVehicle {
                HomeRouter.makeMileageListView(
                    modelContainer: viewModel.modelContainer,
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
            await syncData()
        }
        .onChange(of: state, { _, newValue in
            isLoading = newValue == .loading

            isNewVehiclePresented = newValue == .newVehicle
        })
        .onShake {
            isPulseConsolePresented = true
        }
        .sheet(isPresented: $isNewVehiclePresented) {
            viewModel.showEditVehicleView(
                vehicleId: selectedVehicle?.id,
                isPresented: $isNewVehiclePresented
            )
        }
        .sheet(isPresented: $isPulseConsolePresented) {
            viewModel.showPulseUI()
        }
    }
    
    func syncData() async {
        await stateStore.store(await viewModel.stateStore.statePublisher.sink { self.state = $0})
        await stateStore.store(await viewModel.stateStore.selectedVehiclePublisher.sink { self.selectedVehicle = $0 })
        
        await viewModel.fetchData()
    }
}

#Preview {
    HomeView(
        viewModel: HomeView.ViewModel(modelContainer: SwiftDataManager.shared.previewModelContainer),
    )
}
