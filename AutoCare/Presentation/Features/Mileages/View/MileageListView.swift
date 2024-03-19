//
//  MileageListView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import SwiftUI
import Realm
import TTProgressHUD

struct MileageListView: View {
    @EnvironmentObject var app: RLMApp
    
    @ObservedObject var viewModel: ViewModel
    @State private var isLoading = true
    @State private var isNewVehiclePresented = false
    @State private var selectedVehicleId: String? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(viewModel.vehicleMileages, id: \.id) { vehicleMileage in
                    NavigationLink(value: vehicleMileage.id) {
                        MileageListItem(vehicleMileage: vehicleMileage)
                    }
                }
            }
            .toolbar {
                Button(action: {}) {
                    NavigationLink {
//                        viewModel.showMileageEditView(
//                            navigationPath: $presentedMileages
//                        )
                    } label: {
                        Image(systemName: "plus")
                    }
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
        .sheet(isPresented: $isNewVehiclePresented) {
            if app.currentUser != nil,
               let realm = viewModel.realm {
                viewModel.showEditVehicleView(
                    realm: realm,
                    vehicleId: $selectedVehicleId.wrappedValue,
                    isPresented: $isNewVehiclePresented
                )
            }
        }
    }
}

#Preview {
    MileageListView(viewModel: MileageListView.ViewModel())
}
