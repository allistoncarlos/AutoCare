//
//  HomeView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 09/11/24.
//

import SwiftData
import SwiftUI
import TTProgressHUD

private enum HomeTab: Hashable {
    case dashboard
    case services
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeView.ViewModel
    @State private var selectedTab: HomeTab = .dashboard
    @State private var isLoading = false
    @State private var isNewVehiclePresented = false
    @State private var isPulseConsolePresented = false

    @Environment(\.colorScheme) private var colorScheme

    init(viewModel: HomeView.ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            if let selectedVehicle = viewModel.selectedVehicle {
                HomeRouter.makeMileageListView(
                    selectedVehicle: selectedVehicle,
                    onVehiclePickerTap: viewModel.openVehiclePicker
                )
                .id(selectedVehicle.clientId)
                .tag(HomeTab.dashboard)
                .tabItem {
                    Label("Dashboard", systemImage: "gauge.with.dots.needle.67percent")
                }

                HomeRouter.makeServiceListView(
                    selectedVehicle: selectedVehicle,
                    onVehiclePickerTap: viewModel.openVehiclePicker
                )
                .id(selectedVehicle.clientId)
                .tag(HomeTab.services)
                .tabItem {
                    Label("Serviços", systemImage: "car.badge.gearshape")
                }
            }
        }
        .tint(BrandTheme.Colors.violetCore)
        .onAppear {
            configureTabBarAppearance()
        }
        .disabled(isLoading)
        .overlay(
            TTProgressHUD($isLoading, config: AutoCareApp.hudConfig)
        )
        .task {
            await viewModel.syncAndFetchData()
        }
        .onChange(of: isNewVehiclePresented) { _, newValue in
            if !newValue {
                Task { await viewModel.fetchData() }
            }
        }
        .onChange(of: viewModel.state) { _, newValue in
            isLoading = newValue == .loading
            isNewVehiclePresented = newValue == .newVehicle
        }
        .onShake {
            isPulseConsolePresented = true
        }
        .sheet(isPresented: $isNewVehiclePresented) {
            viewModel.showEditVehicleView(
                vehicleId: viewModel.selectedVehicle?.id,
                isPresented: $isNewVehiclePresented
            )
        }
        .sheet(isPresented: $viewModel.isVehiclePickerPresented) {
            VehiclePickerSheet(
                vehicles: viewModel.vehicles,
                selectedVehicle: viewModel.selectedVehicle,
                onSelect: viewModel.selectVehicle,
                onAddVehicle: {
                    viewModel.isVehiclePickerPresented = false
                    isNewVehiclePresented = true
                }
            )
        }
        .sheet(isPresented: $isPulseConsolePresented) {
            viewModel.showPulseUI()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(BrandTheme.Colors.backgroundSurface(colorScheme))

        let normalColor = UIColor(BrandTheme.Colors.textMuted(colorScheme))
        let selectedColor = UIColor(BrandTheme.Colors.violetCore)
        let tabFont = BrandTheme.Typography.uiFontBody(size: 10, weight: .medium)

        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor,
            .font: tabFont
        ]
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: tabFont
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    HomeView(viewModel: HomeView.ViewModel())
        .modelContainer(SwiftDataManager.shared.previewModelContainer)
        .preferredColorScheme(.dark)
}
