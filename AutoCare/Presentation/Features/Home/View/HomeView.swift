//
//  HomeView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 09/11/24.
//

import SwiftUI
import Realm
import TTProgressHUD

struct HomeView: View {
    @EnvironmentObject var app: RLMApp
    @ObservedObject var viewModel: HomeView.ViewModel
    @State private var isLoading = true
    @State private var isNewVehiclePresented = false
    @State private var selectedVehicleMileage: VehicleMileage? = nil

    @State private var presentedMileages = NavigationPath()
    
    var body: some View {
        TabView {
            if let realm = viewModel.realm, let selectedVehicle = viewModel.selectedVehicle {
                HomeRouter.makeMileageListView(realm: realm, selectedVehicle: selectedVehicle)
                    .environmentObject(app)
                    .tabItem {
                        Label("Dashboard", systemImage: "display")
                    }
                
                HomeRouter.makeServiceListView(realm: realm, selectedVehicle: selectedVehicle)
                    .environmentObject(app)
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
            await viewModel.setup(app: app)
        }
        .onChange(of: viewModel.state, { _, newState in
            isLoading = newState == .loading
            
            isNewVehiclePresented = newState == .newVehicle
        })
    }
}

#Preview {
    HomeView(viewModel: HomeView.ViewModel())
}
