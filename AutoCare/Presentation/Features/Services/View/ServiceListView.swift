//
//  ServiceListView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import SwiftData
import SwiftUI
import TTProgressHUD

struct ServiceListView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var presentedServices = NavigationPath()

    init(viewModel: ServiceListView.ViewModel) {
        self.viewModel = viewModel
    }

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
                .disabled(viewModel.state == .loading)
            }
            .navigationDestination(for: String.self) { _ in
                if let id = viewModel.selectedVehicle.id {
                    navigateToEditServiceView(vehicleId: id)
                }
            }
            .navigationDestination(for: VehicleService.self) { vehicleService in
                if let id = viewModel.selectedVehicle.id {
                    navigateToEditServiceView(
                        vehicleId: id,
                        vehicleService: vehicleService
                    )
                }
            }
        }
        .disabled(viewModel.state == .loading)
        .overlay(
            TTProgressHUD(
                .constant(viewModel.state == .loading),
                config: AutoCareApp.hudConfig
            )
        )
        .task {
            await viewModel.fetchData()
        }
        .onChange(of: presentedServices) { _, newValue in
            if newValue.isEmpty {
                Task { await viewModel.fetchData() }
            }
        }
    }

    func navigateToEditServiceView(
        vehicleId: String,
        vehicleService: VehicleService? = nil
    ) -> some View {
        viewModel.editServiceView(
            navigationPath: $presentedServices,
            vehicleId: vehicleId,
            vehicleService: vehicleService
        )
    }
}

#Preview {
    ServiceListView(
        viewModel: ServiceListView.ViewModel(
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
    .modelContainer(SwiftDataManager.shared.previewModelContainer)
}
