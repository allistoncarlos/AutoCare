//
//  MileageFormView.swift
//  AutoCare Watch App
//

import SwiftUI

struct MileageFormView: View {
    @StateObject private var viewModel: MileageFormViewModel
    @Environment(\.dismiss) private var dismiss

    private let onAppearSelect: (() -> Void)?

    init(vehicle: WatchVehicle, onAppearSelect: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: MileageFormViewModel(vehicle: vehicle))
        self.onAppearSelect = onAppearSelect
    }

    var body: some View {
        Form {
            Section("Abastecimento") {
                NavigationLink {
                    WatchMoneyPickerView(
                        cents: $viewModel.totalCostCents,
                        title: "Custo total",
                        maxReais: 2_000
                    )
                } label: {
                    LabeledContent("Custo total", value: viewModel.totalCostLabel)
                }

                NavigationLink {
                    WatchMoneyPickerView(
                        cents: $viewModel.fuelCostCents,
                        title: "Preço/L",
                        maxReais: 20
                    )
                } label: {
                    LabeledContent("Preço/L", value: viewModel.fuelCostLabel)
                }

                if viewModel.isComplete {
                    LabeledContent("Litros", value: viewModel.litersLabel)
                } else {
                    NavigationLink {
                        WatchLitersPickerView(
                            milliLiters: $viewModel.litersMilli,
                            title: "Litros",
                            maxLiters: 200
                        )
                    } label: {
                        LabeledContent("Litros", value: viewModel.litersLabel)
                    }
                }

                NavigationLink {
                    WatchOdometerPickerView(
                        odometer: $viewModel.odometer,
                        title: "Odômetro",
                        range: viewModel.odometerRange
                    )
                } label: {
                    LabeledContent("Odômetro", value: viewModel.odometerLabel)
                }

                Toggle("Completo", isOn: $viewModel.isComplete)
            }

            if hasPreviousMileage {
                Section("Anterior") {
                    if let lastOdometer = viewModel.vehicle.lastOdometer {
                        LabeledContent("Odômetro", value: "\(lastOdometer) km")
                    }
                    if let fuel = viewModel.vehicle.lastFuelCost {
                        LabeledContent(
                            "Preço/L",
                            value: String(format: "R$ %.2f", fuel).replacingOccurrences(of: ".", with: ",")
                        )
                    }
                    if let total = viewModel.vehicle.lastTotalCost {
                        LabeledContent(
                            "Custo total",
                            value: String(format: "R$ %.2f", total).replacingOccurrences(of: ".", with: ",")
                        )
                    }
                }
            }

            Section {
                Button {
                    Task { await viewModel.save() }
                } label: {
                    if viewModel.uiState == .saving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Salvar")
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.canSave)
            }
        }
        .navigationTitle(viewModel.vehicle.name)
        .onAppear {
            onAppearSelect?()
            viewModel.recalculateLitersIfNeeded()
        }
        .onChange(of: viewModel.totalCostCents) { _, _ in
            viewModel.recalculateLitersIfNeeded()
        }
        .onChange(of: viewModel.fuelCostCents) { _, _ in
            viewModel.recalculateLitersIfNeeded()
        }
        .onChange(of: viewModel.isComplete) { _, isComplete in
            if isComplete {
                viewModel.recalculateLitersIfNeeded()
            } else if viewModel.litersMilli == 0, let lastLiters = viewModel.vehicle.lastLiters {
                viewModel.litersMilli = Int((lastLiters * 1_000.0).rounded())
            }
        }
        .alert("Salvo", isPresented: successBinding) {
            Button("OK") {
                viewModel.resetAfterSuccess()
                dismiss()
            }
        } message: {
            if case let .success(diff, mileage) = viewModel.uiState {
                Text("\(diff) km · \(String(format: "%.2f", mileage).replacingOccurrences(of: ".", with: ",")) km/L")
            }
        }
        .alert("Erro", isPresented: errorBinding) {
            Button("OK") {
                viewModel.uiState = .editing
            }
        } message: {
            if case let .error(message) = viewModel.uiState {
                Text(message)
            }
        }
    }

    private var hasPreviousMileage: Bool {
        viewModel.vehicle.lastOdometer != nil
            || viewModel.vehicle.lastFuelCost != nil
            || viewModel.vehicle.lastTotalCost != nil
    }

    private var successBinding: Binding<Bool> {
        Binding(
            get: {
                if case .success = viewModel.uiState { return true }
                return false
            },
            set: { _ in }
        )
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: {
                if case .error = viewModel.uiState { return true }
                return false
            },
            set: { _ in }
        )
    }
}
