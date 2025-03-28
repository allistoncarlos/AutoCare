//
//  MileageListView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import SwiftUI
import TTProgressHUD
import SwiftData

struct MileageListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject var viewModel: ViewModel
    @State private var isLoading = true
    @State private var isNewVehiclePresented = false

    @State private var presentedMileages = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $presentedMileages) {
            ScrollView {
                ForEach(viewModel.vehicleMileagesData, id: \.id) { vehicleMileage in
                    NavigationLink(value: vehicleMileage) {
                        MileageListItem(vehicleMileage: vehicleMileage)
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
            .navigationDestination(for: String.self) { _ in
                navigateToEditMileageView(vehicleId: viewModel.selectedVehicle.id)
            }
            .navigationDestination(for: VehicleMileage.self) { vehicleMileage in
                navigateToEditMileageView(
                    vehicleId: viewModel.selectedVehicle.id,
                    vehicleMileage: vehicleMileage
                )
            }
        }
        .disabled(isLoading)
        .overlay(
            TTProgressHUD($isLoading, config: AutoCareApp.hudConfig)
        )
        .task {
//            await viewModel.setup(app: app)
//            await viewModel.fetchData() // TODO: refatorar pra isso
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
                    await viewModel.fetchVehicleMileages()
                }
            }
        }
    }
    
    func navigateToEditMileageView(
        vehicleId: String,
        vehicleMileage: VehicleMileage? = nil
    ) -> some View {
        return viewModel.editMileageView(
            navigationPath: $presentedMileages,
            vehicleId: vehicleId,
            vehicleMileage: vehicleMileage
        )
    }
}

//#Preview {
//    MileageListView(
//        viewModel: MileageListView.ViewModel(
//            realm: try! Realm(),
//            selectedVehicle: Vehicle(
//                name: "Fiat Argo 2021",
//                brand: "Fiat",
//                model: "Argo",
//                year: "2021",
//                licensePlate: "AAA-1C34",
//                odometer: 0,
//                owner_id: "11234",
//                vehicleType: VehicleType(name: "Car")
//            )
//        )
//    )
//}
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    
    MileageListView(
        viewModel: MileageListView.ViewModel(
            modelContext: ModelContext(
                try! ModelContainer(for: VehicleMileage.self, configurations: config)
            ),
            selectedVehicle: Vehicle(
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
    .modelContainer(for: VehicleMileage.self, inMemory: true)
}
