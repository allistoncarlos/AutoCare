//
//  VehicleListView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import SwiftUI
import TTProgressHUD
import SwiftData

struct VehicleListView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var viewModel: ViewModel
    @State var isLoading = true
    
    @State private var presentedVehicles = NavigationPath()

    var body: some View {
        NavigationStack(path: $presentedVehicles) {
            VStack {
                List(viewModel.vehicles, id: \.id) { vehicle in
                    NavigationLink(vehicle.name, value: vehicle.id)
                }
            }
            .disabled(isLoading)
            .padding(.top, 10)
//            .navigationDestination(for: String.self) { vehicleId in
//                viewModel.editVehicleView(
//                    navigationPath: $presentedVehicles,
//                    platformId: vehicleId
//                )
//            }
            .navigationTitle("Veículos")
            .toolbar {
                Button(action: {}) {
                    NavigationLink(value: String()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .overlay(
            TTProgressHUD($isLoading, config: AutoCareApp.hudConfig)
        )
        .onChange(of: presentedVehicles, { _, newValue in
            if newValue.isEmpty {
                Task {
                    await viewModel.fetchVehicles()
                }
            }
        })
        .onChange(of: viewModel.state, { _, newState in
            isLoading = newState == .loading
        })
        .task {
            await viewModel.fetchVehicles()
        }
    }
}

#Preview {
    VehicleListView(viewModel: VehicleListView.ViewModel(modelContext: SwiftDataManager.shared.previewModelContext))
}
