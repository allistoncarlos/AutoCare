//
//  MileageListView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import SwiftData
import SwiftUI
import TTProgressHUD

struct MileageListView: View {
    @ObservedObject var viewModel: MileageListViewModel
    @State private var presentedMileages = NavigationPath()

    init(viewModel: MileageListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack(path: $presentedMileages) {
            ScrollView {
                ForEach(viewModel.vehicleMileages, id: \.id) { vehicleMileage in
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
                .disabled(viewModel.state == .loading)
            }
            .navigationDestination(for: String.self) { _ in
                if let id = viewModel.selectedVehicle.id {
                    navigateToEditMileageView(vehicleId: id)
                }
            }
            .navigationDestination(for: VehicleMileage.self) { vehicleMileage in
                if let id = viewModel.selectedVehicle.id {
                    navigateToEditMileageView(
                        vehicleId: id,
                        vehicleMileage: vehicleMileage
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
        .onChange(of: presentedMileages) { _, newValue in
            if newValue.isEmpty {
                Task { await viewModel.fetchData() }
            }
        }
    }

    func navigateToEditMileageView(
        vehicleId: String,
        vehicleMileage: VehicleMileage? = nil
    ) -> some View {
        viewModel.editMileageView(
            navigationPath: $presentedMileages,
            vehicleId: vehicleId,
            vehicleMileage: vehicleMileage
        )
    }
}

#Preview {
    MileageListView(
        viewModel: MileageListViewModel(
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
