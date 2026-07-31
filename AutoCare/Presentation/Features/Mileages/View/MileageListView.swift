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
    @StateObject private var viewModel: ViewModel
    @State private var presentedMileages = NavigationPath()

    let onVehiclePickerTap: () -> Void

    init(selectedVehicle: Vehicle, onVehiclePickerTap: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: ViewModel(selectedVehicle: selectedVehicle))
        self.onVehiclePickerTap = onVehiclePickerTap
    }

    var body: some View {
        NavigationStack(path: $presentedMileages) {
            VStack(spacing: 0) {
                BrandScreenHeader(
                    title: viewModel.selectedVehicle.name,
                    onTitleTap: onVehiclePickerTap
                ) {
                    Button(action: {}) {
                        NavigationLink(value: MileageRoute.new) {
                            BrandToolbarIconButton(systemName: "plus")
                        }
                    }
                    .disabled(viewModel.state == .loading)
                }

                List {
                    if viewModel.vehicleMileages.isEmpty {
                        if viewModel.state != .loading {
                            Section {
                                BrandEmptyState(
                                    icon: "fuelpump.fill",
                                    title: "Nenhum abastecimento",
                                    message: "Toque em + para registrar o primeiro abastecimento."
                                )
                                .frame(maxWidth: .infinity)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            }
                        }
                    } else {
                        Section {
                            ForEach(viewModel.vehicleMileages, id: \.clientId) { vehicleMileage in
                                NavigationLink(value: MileageRoute.edit(clientId: vehicleMileage.clientId)) {
                                    MileageListItem(vehicleMileage: vehicleMileage)
                                }
                                .brandFormListRow()
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
            .navigationDestination(for: MileageRoute.self) { route in
                switch route {
                case .new:
                    navigateToEditMileageView(vehicleId: viewModel.selectedVehicle.referenceId)
                case let .edit(clientId):
                    navigateToEditMileageView(
                        vehicleId: viewModel.selectedVehicle.referenceId,
                        mileageClientId: clientId
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
        .onChange(of: presentedMileages) { _, newValue in
            if newValue.isEmpty {
                Task { await viewModel.fetchData() }
            }
        }
    }

    func navigateToEditMileageView(
        vehicleId: String,
        mileageClientId: String? = nil
    ) -> some View {
        viewModel.editMileageView(
            navigationPath: $presentedMileages,
            vehicleId: vehicleId,
            mileageClientId: mileageClientId
        )
    }
}

#Preview {
    MileageListView(
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
