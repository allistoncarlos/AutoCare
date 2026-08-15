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
                        NavigationLink(value: ServiceRoute.new) {
                            BrandToolbarIconButton(systemName: "plus")
                        }
                    }
                    .disabled(viewModel.state == .loading)
                }

                List {
                    if viewModel.vehicleServices.isEmpty {
                        if viewModel.state != .loading {
                            Section {
                                BrandEmptyState(
                                    icon: "wrench.and.screwdriver.fill",
                                    title: "Nenhum serviço",
                                    message: "Toque em + para registrar uma manutenção."
                                )
                                .frame(maxWidth: .infinity)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                    } else {
                        Section {
                            ForEach(viewModel.vehicleServices, id: \.clientId) { vehicleService in
                                NavigationLink(value: ServiceRoute.edit(clientId: vehicleService.clientId)) {
                                    ServiceListItem(vehicleService: vehicleService)
                                }
                                .brandFormListRow()
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task { await viewModel.deleteService(vehicleService) }
                                    } label: {
                                        Label("Excluir", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .listSectionMargins(.horizontal, 20)
                .brandScreen()
            }
            .brandBackground()
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: ServiceRoute.self) { route in
                switch route {
                case .new:
                    navigateToEditServiceView(vehicleId: viewModel.selectedVehicle.referenceId)
                case let .edit(clientId):
                    navigateToEditServiceView(
                        vehicleId: viewModel.selectedVehicle.referenceId,
                        serviceClientId: clientId
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
        serviceClientId: String? = nil
    ) -> some View {
        viewModel.editServiceView(
            navigationPath: $presentedServices,
            vehicleId: vehicleId,
            serviceClientId: serviceClientId
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
