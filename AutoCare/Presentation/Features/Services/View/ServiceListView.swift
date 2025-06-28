//
//  ServiceListView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import SwiftUI
import TTProgressHUD
import SwiftData

struct ServiceListView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var isLoading = true
    @State private var isNewVehiclePresented = false

    @State private var presentedServices = NavigationPath()
    @State private var vehicleServices = [VehicleService]()
    @State private var selectedVehicle: Vehicle?
    
    @State private var stateStore = ServiceListView.ViewModel.ViewModelState()
    @State private var state: ServiceListState = .idle
    
    init(viewModel: ServiceListView.ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationStack(path: $presentedServices) {
            ScrollView {
                ForEach(vehicleServices, id: \.id) { vehicleService in
                    NavigationLink(value: vehicleService) {
                        ServiceListItem(vehicleService: vehicleService)
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
                    navigateToEditServiceView(vehicleId: id)
                }
            }
            .navigationDestination(for: VehicleService.self) { vehicleService in
                if let id = selectedVehicle?.id {
                    navigateToEditServiceView(
                        vehicleId: id,
                        vehicleService: vehicleService
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
        .onChange(of: presentedServices) {
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
        await stateStore.store(await viewModel.stateStore.vehicleServicesPublisher.sink { self.vehicleServices = $0 })
        
        await viewModel.fetchData()
    }
    
    func navigateToEditServiceView(
        vehicleId: String,
        vehicleService: VehicleService? = nil
    ) -> some View {
        return viewModel.editServiceView(
            navigationPath: $presentedServices,
            vehicleId: vehicleId,
            vehicleService: vehicleService
        )
    }
}

#Preview {
    ServiceListView(
        viewModel: ServiceListView.ViewModel(
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
