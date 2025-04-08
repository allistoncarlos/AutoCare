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
    @ObservedObject var viewModel: ViewModel
    @State private var isLoading = true
    @State private var isNewVehiclePresented = false

    @State private var presentedMileages = NavigationPath()
    @State private var vehicleMileages = [VehicleMileage]()
    @State private var selectedVehicle: Vehicle?
    
    @State private var stateStore = MileageListView.ViewModel.ViewModelState()
    @State private var state: MileageListState = .idle
    
    init(viewModel: MileageListView.ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack(path: $presentedMileages) {
            ScrollView {
                ForEach(vehicleMileages, id: \.id) { vehicleMileage in
                    NavigationLink(value: vehicleMileage) {
                        MileageListItem(vehicleMileage: vehicleMileage)
                    }
                }
            }
            .navigationView(title: selectedVehicle?.name ?? "")
            .toolbar {
                Button(action: {}) {
                    NavigationLink(value: String()) {
                        Image(systemName: "plus")
                    }
                }
                .disabled(isLoading)
            }
            .navigationDestination(for: String.self) { _ in
                if let id = selectedVehicle?.id {
                    navigateToEditMileageView(vehicleId: id)
                }
            }
            .navigationDestination(for: VehicleMileage.self) { vehicleMileage in
                if let id = selectedVehicle?.id {
                    navigateToEditMileageView(
                        vehicleId: id,
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
            await syncData()
        }
        .onChange(of: state, { _, newValue in
            isLoading = newValue == .loading

            isNewVehiclePresented = newValue == .newVehicle
        })
        .onChange(of: presentedMileages) {
            oldValue,
            newValue in
            if newValue.isEmpty {
                Task {
                    await viewModel.fetchData()
                }
            }
        }
    }
    
    func syncData() async {
        await stateStore.store(await viewModel.stateStore.statePublisher.sink { self.state = $0})
        await stateStore.store(await viewModel.stateStore.selectedVehiclePublisher.sink { self.selectedVehicle = $0 })
        await stateStore.store(await viewModel.stateStore.vehicleMileagesPublisher.sink { self.vehicleMileages = $0 })
        
        await viewModel.fetchData()
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

#Preview {
    MileageListView(
        viewModel: MileageListView.ViewModel(
            modelContainer: SwiftDataManager.shared.previewModelContainer,
            selectedVehicle: Vehicle(
                id: "1",
                name: "Fiat Argo 2021",
                brand: "Fiat",
                model: "Argo",
                year: "2021",
                licensePlate: "AAA-1C34",
                odometer: 0,
                isDefault: true,
                vehicleTypeId: "1"
            )
        )
    )
}
