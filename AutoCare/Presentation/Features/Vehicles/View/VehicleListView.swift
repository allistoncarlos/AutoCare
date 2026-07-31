//
//  VehicleListView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import SwiftData
import SwiftUI
import TTProgressHUD

struct VehicleListView: View {
    @ObservedObject var viewModel: ViewModel
    @State var isLoading = true

    @State private var presentedVehicles = NavigationPath()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack(path: $presentedVehicles) {
            ScrollView {
                LazyVStack(spacing: BrandTheme.Spacing.sm) {
                    if viewModel.vehicles.isEmpty {
                        BrandEmptyState(
                            icon: "car.fill",
                            title: "Nenhum veículo",
                            message: "Toque em + para cadastrar seu veículo."
                        )
                        .padding(.top, BrandTheme.Spacing.xxl)
                    } else {
                        BrandSectionHeader(title: "Veículos", accent: BrandTheme.Colors.violetSoft)
                            .padding(.horizontal, BrandTheme.Spacing.lg)
                            .padding(.top, BrandTheme.Spacing.sm)

                        ForEach(viewModel.vehicles, id: \.id) { vehicle in
                            NavigationLink(value: vehicle.id) {
                                BrandListRow(
                                    icon: "car.fill",
                                    title: vehicle.name,
                                    subtitle: "\(vehicle.brand) \(vehicle.model) · \(vehicle.licensePlate)"
                                )
                                .padding(BrandTheme.Spacing.md)
                                .background(BrandTheme.Colors.backgroundSurface(colorScheme))
                                .clipShape(RoundedRectangle(cornerRadius: BrandTheme.Radius.lg))
                                .overlay(
                                    RoundedRectangle(cornerRadius: BrandTheme.Radius.lg)
                                        .stroke(BrandTheme.Colors.border(colorScheme), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal, BrandTheme.Spacing.lg)
                        }
                    }
                }
                .padding(.bottom, BrandTheme.Spacing.lg)
            }
            .brandScreen()
            .navigationTitle("Veículos")
            .toolbar {
                Button(action: {}) {
                    NavigationLink(value: String()) {
                        BrandAddToolbarButton()
                    }
                }
            }
        }
        .tint(BrandTheme.Colors.violetCore)
        .overlay(
            TTProgressHUD($isLoading, config: AutoCareApp.hudConfig)
        )
        .onChange(of: presentedVehicles, { _, newValue in
            if newValue.isEmpty {
                Task {
                    await viewModel.fetchVehicles()
                }
            }
        })
        .onChange(of: viewModel.state, { _, newState in
            isLoading = newState == .loading
        })
        .task {
            await viewModel.fetchVehicles()
        }
    }
}

#Preview {
    VehicleListView(viewModel: VehicleListView.ViewModel())
        .modelContainer(SwiftDataManager.shared.previewModelContainer)
        .preferredColorScheme(.dark)
}
