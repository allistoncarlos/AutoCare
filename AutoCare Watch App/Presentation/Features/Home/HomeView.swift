//
//  HomeView.swift
//  AutoCare Watch App
//

import SwiftUI

enum WatchHomeRoute: Hashable {
    case vehicleList
    case amount
    case price
    case odometer
    case confirm
    case liters
    case success
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var path = NavigationPath()
    @State private var selectedVehicleId = WatchVehicleSelectionStore.lastSelectedVehicleId
    @State private var fuelForm: MileageFormViewModel?

    var body: some View {
        NavigationStack(path: $path) {
            root
                .navigationDestination(for: WatchHomeRoute.self, destination: destination)
        }
        .tint(WatchTheme.violet)
    }

    private var root: some View {
        Group {
            switch viewModel.uiState {
            case .loading:
                ProgressView("Carregando…")
                    .navigationTitle("AutoCare")
            case .notLogged:
                NotLoggedView()
                    .navigationTitle("AutoCare")
            case .empty:
                ContentUnavailableView(
                    "Sem veículos",
                    systemImage: "car.fill",
                    description: Text("Cadastre um veículo no iPhone.")
                )
                .navigationTitle("AutoCare")
            case let .error(message):
                ContentUnavailableView(
                    "Erro",
                    systemImage: "exclamationmark.triangle",
                    description: Text(message)
                )
                .navigationTitle("AutoCare")
            case .content:
                if let vehicle = displayedVehicle {
                    VehicleSummaryView(
                        vehicle: vehicle,
                        canSwitch: viewModel.vehicles.count > 1,
                        onSwitch: { path.append(WatchHomeRoute.vehicleList) },
                        onFuel: { startFuelLog(for: vehicle) }
                    )
                } else {
                    vehicleList { vehicle in
                        select(vehicle)
                    }
                }
            }
        }
        .task { await viewModel.load() }
        .refreshable { await viewModel.load() }
    }

    private var displayedVehicle: WatchVehicle? {
        let vehicles = viewModel.vehicles
        if let selectedVehicleId,
           let match = vehicles.first(where: { $0.id == selectedVehicleId }) {
            return match
        }
        return WatchVehicleSelectionStore.preferredVehicle(from: vehicles)
    }

    @ViewBuilder
    private func destination(_ route: WatchHomeRoute) -> some View {
        switch route {
        case .vehicleList:
            vehicleList { vehicle in
                select(vehicle)
                if !path.isEmpty {
                    path.removeLast()
                }
            }
        case .amount:
            fuelScreen { form in
                FuelAmountKeypadView(viewModel: form) {
                    path.append(WatchHomeRoute.price)
                }
            }
        case .price:
            fuelScreen { form in
                FuelPriceStepView(viewModel: form) {
                    path.append(WatchHomeRoute.odometer)
                }
            }
        case .odometer:
            fuelScreen { form in
                FuelOdometerStepView(viewModel: form) {
                    form.recalculateLitersIfNeeded()
                    path.append(WatchHomeRoute.confirm)
                }
            }
        case .confirm:
            fuelScreen { form in
                FuelConfirmView(viewModel: form) {
                    path.append(WatchHomeRoute.liters)
                } onSaved: {
                    path.append(WatchHomeRoute.success)
                }
            }
        case .liters:
            fuelScreen { form in
                FuelLitersStepView(viewModel: form) {
                    if !path.isEmpty {
                        path.removeLast()
                    }
                }
            }
        case .success:
            fuelScreen { form in
                FuelSuccessView(viewModel: form) {
                    fuelForm = nil
                    path = NavigationPath()
                    Task { await viewModel.load() }
                }
            }
        }
    }

    private func vehicleList(onSelect: @escaping (WatchVehicle) -> Void) -> some View {
        VehicleListView(
            vehicles: viewModel.vehicles,
            lastSelectedVehicleId: selectedVehicleId ?? WatchVehicleSelectionStore.lastSelectedVehicleId,
            onSelect: onSelect
        )
    }

    @ViewBuilder
    private func fuelScreen<Content: View>(@ViewBuilder content: (MileageFormViewModel) -> Content) -> some View {
        if let fuelForm {
            content(fuelForm)
        } else {
            ProgressView()
        }
    }

    private func select(_ vehicle: WatchVehicle) {
        selectedVehicleId = vehicle.id
        WatchVehicleSelectionStore.remember(vehicle.id)
    }

    private func startFuelLog(for vehicle: WatchVehicle) {
        select(vehicle)
        fuelForm = MileageFormViewModel(vehicle: vehicle)
        path.append(WatchHomeRoute.amount)
    }
}

#Preview {
    HomeView()
}
