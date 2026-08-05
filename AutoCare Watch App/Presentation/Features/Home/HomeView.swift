//
//  HomeView.swift
//  AutoCare Watch App
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var navigationPath = NavigationPath()
    @State private var didAutoOpenPreferredVehicle = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                switch viewModel.uiState {
                case .loading:
                    ProgressView("Carregando…")
                case .notLogged:
                    NotLoggedView()
                case .empty:
                    ContentUnavailableView(
                        "Sem veículos",
                        systemImage: "car.fill",
                        description: Text("Cadastre um veículo no iPhone.")
                    )
                case let .error(message):
                    ContentUnavailableView(
                        "Erro",
                        systemImage: "exclamationmark.triangle",
                        description: Text(message)
                    )
                case .content:
                    VehicleListView(
                        vehicles: viewModel.vehicles,
                        lastSelectedVehicleId: WatchVehicleSelectionStore.lastSelectedVehicleId
                    )
                }
            }
            .navigationTitle("AutoCare")
            .navigationDestination(for: String.self) { vehicleId in
                if let vehicle = viewModel.vehicles.first(where: { $0.id == vehicleId }) {
                    MileageFormView(vehicle: vehicle) {
                        WatchVehicleSelectionStore.remember(vehicle.id)
                    }
                }
            }
            .task {
                await viewModel.load()
                openPreferredVehicleIfNeeded()
            }
            .refreshable {
                await viewModel.load()
            }
            .onChange(of: viewModel.vehicles.map(\.id)) { _, _ in
                openPreferredVehicleIfNeeded()
            }
            .onChange(of: viewModel.uiState) { _, newState in
                if newState != .content {
                    didAutoOpenPreferredVehicle = false
                    navigationPath = NavigationPath()
                } else {
                    openPreferredVehicleIfNeeded()
                }
            }
        }
    }

    private func openPreferredVehicleIfNeeded() {
        guard viewModel.uiState == .content,
              !didAutoOpenPreferredVehicle,
              navigationPath.isEmpty,
              let preferred = WatchVehicleSelectionStore.preferredVehicle(from: viewModel.vehicles) else {
            return
        }

        didAutoOpenPreferredVehicle = true
        WatchVehicleSelectionStore.remember(preferred.id)
        navigationPath.append(preferred.id)
    }
}

#Preview {
    HomeView()
}
