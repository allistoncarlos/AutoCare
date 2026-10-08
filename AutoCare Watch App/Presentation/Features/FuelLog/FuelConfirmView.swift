//
//  FuelConfirmView.swift
//  AutoCare Watch App
//

import SwiftUI

struct FuelConfirmView: View {
    @ObservedObject var viewModel: MileageFormViewModel
    let onEditLiters: () -> Void
    let onSaved: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 6) {
                WatchProgressDots(index: 3)

                VStack(spacing: 0) {
                    row("Total", viewModel.totalCostLabel)
                    row("Preço/L", viewModel.fuelCostLabel)
                    row("Litros", viewModel.litersLabel)
                    row("Km", viewModel.odometerLabel)
                    if let distanceKm = viewModel.distanceKm {
                        row("Percorridos", "+\(distanceKm) km", valueColor: WatchTheme.success)
                    }
                }
                .background(Color.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                Toggle(
                    "Completo",
                    isOn: Binding(
                        get: { viewModel.isComplete },
                        set: { isOn in
                            viewModel.setComplete(isOn)
                            if !isOn {
                                onEditLiters()
                            }
                        }
                    )
                )
                .font(.caption)

                Button {
                    Task { await viewModel.save() }
                } label: {
                    if viewModel.uiState == .saving {
                        ProgressView()
                    } else {
                        Text("Registrar")
                    }
                }
                .buttonStyle(WatchPrimaryButtonStyle())
                .disabled(!viewModel.canSave)
            }
        }
        .navigationTitle("Confirmar")
        .onAppear {
            viewModel.step = .confirm
            viewModel.recalculateLitersIfNeeded()
        }
        .onChange(of: viewModel.uiState) { _, newValue in
            if case .success = newValue {
                onSaved()
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

    private func row(_ title: String, _ value: String, valueColor: Color = .primary) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer(minLength: 4)
            Text(value)
                .foregroundStyle(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
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

struct FuelSuccessView: View {
    @ObservedObject var viewModel: MileageFormViewModel
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(WatchTheme.success)

            Text("Salvo")
                .font(.title3.bold())

            Text(viewModel.vehicle.name)
                .font(.caption)
                .foregroundStyle(.secondary)

            if case let .success(difference, mileage) = viewModel.uiState {
                Text("\(difference) km")
                    .font(.title2.bold())

                consumptionLine(mileage)
            }

            Spacer(minLength: 0)

            Button("OK", action: onFinish)
                .buttonStyle(.bordered)
        }
        .navigationTitle("Salvo")
        .navigationBarBackButtonHidden(true)
    }

    private func consumptionLine(_ mileage: Double) -> some View {
        let parts = WatchNumberFormatting.consumption(mileage)
        return HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(parts.number)
                .font(.title2.bold())
            Text(parts.unit)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
}
