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
    @StateObject private var viewModel: ViewModel
    @State private var presentedServices = NavigationPath()

    let onVehiclePickerTap: () -> Void

    init(selectedVehicle: Vehicle, onVehiclePickerTap: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: ViewModel(selectedVehicle: selectedVehicle))
        self.onVehiclePickerTap = onVehiclePickerTap
    }

    var body: some View {
        NavigationStack(path: $presentedServices) {
            VStack(spacing: 0) {
                BrandScreenHeader(
                    title: viewModel.selectedVehicle.name,
                    onTitleTap: onVehiclePickerTap
                ) {
                    Button(action: {}) {
                        NavigationLink(value: String()) {
                            BrandToolbarIconButton(systemName: "plus")
                        }
                    }
                    .disabled(viewModel.state == .loading)
                }

                ScrollView {
                    LazyVStack(spacing: BrandTheme.Spacing.sm) {
                        if viewModel.vehicleServices.isEmpty {
                            if viewModel.state != .loading {
                                BrandEmptyState(
                                    icon: "wrench.and.screwdriver.fill",
                                    title: "Nenhum serviço",
                                    message: "Toque em + para registrar uma manutenção."
                                )
                                .padding(.top, BrandTheme.Spacing.xl)
                            }
                        } else {
                            ForEach(viewModel.vehicleServices, id: \.id) { vehicleService in
                                NavigationLink(value: vehicleService) {
                                    ServiceListItem(vehicleService: vehicleService)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, BrandTheme.Spacing.lg)
                            }
                        }
                    }
                    .padding(.bottom, BrandTheme.Spacing.lg)
                }
            }
            .brandScreen()
            .toolbar(.hidden, for: .navigationBar)
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
        .tint(BrandTheme.Colors.violetCore)
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
        ),
        onVehiclePickerTap: {}
    )
    .modelContainer(SwiftDataManager.shared.previewModelContainer)
    .preferredColorScheme(.dark)
}
