//
//  FuelCrownStepsView.swift
//  AutoCare Watch App
//

import SwiftUI

struct FuelPriceStepView: View {
    @ObservedObject var viewModel: MileageFormViewModel
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            WatchProgressDots(index: 1)

            Text(viewModel.fuelCostLabel)
                .font(.system(.title, design: .rounded).weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            if let lastFuelCostLabel = viewModel.lastFuelCostLabel {
                Text("último: \(lastFuelCostLabel)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Button(action: viewModel.togglePriceStep) {
                Text(viewModel.priceStepLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(WatchTheme.violet, in: Capsule())
            }
            .buttonStyle(.plain)

            WatchCrownHint()

            Spacer(minLength: 0)

            Button("Continuar", action: onContinue)
                .buttonStyle(WatchPrimaryButtonStyle())
                .disabled(!viewModel.canContinuePrice)
        }
        .navigationTitle("Preço/L")
        .watchCrown(value: $viewModel.fuelCostCents, step: viewModel.priceStepCents, range: viewModel.priceRange)
        .onAppear { viewModel.step = .price }
    }
}

struct FuelOdometerStepView: View {
    @ObservedObject var viewModel: MileageFormViewModel
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            WatchProgressDots(index: 2)

            Text(viewModel.odometerLabel)
                .font(.system(.title, design: .rounded).weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            if let distanceKm = viewModel.distanceKm {
                Text("+\(distanceKm) km")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(WatchTheme.success)
            }

            Text("passo")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                stepButton(1)
                stepButton(10)
                stepButton(100)
            }

            WatchCrownHint()

            Spacer(minLength: 0)

            Button("Continuar", action: onContinue)
                .buttonStyle(WatchPrimaryButtonStyle())
                .disabled(!viewModel.canContinueOdometer)
        }
        .navigationTitle("Odômetro")
        .watchCrown(value: $viewModel.odometer, step: viewModel.odometerStep, range: viewModel.odometerRange)
        .onAppear { viewModel.step = .odometer }
    }

    private func stepButton(_ step: Int) -> some View {
        let selected = viewModel.odometerStep == step
        return Button {
            viewModel.odometerStep = step
        } label: {
            Text("\(step)")
                .font(.caption.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(selected ? WatchTheme.violet : Color.primary.opacity(0.15), in: Capsule())
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
}

struct FuelLitersStepView: View {
    @ObservedObject var viewModel: MileageFormViewModel
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            Text(viewModel.litersLabel)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text("passo")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                literStepButton(milli: 100, title: "0,1")
                literStepButton(milli: 1_000, title: "1")
            }

            WatchCrownHint()

            Spacer(minLength: 0)

            Button("Continuar", action: onContinue)
                .buttonStyle(WatchPrimaryButtonStyle())
                .disabled(!viewModel.canContinueLiters)
        }
        .navigationTitle("Litros")
        .watchCrown(value: $viewModel.litersMilli, step: viewModel.literStepMilli, range: viewModel.litersRange)
        .onAppear { viewModel.step = .liters }
    }

    private func literStepButton(milli: Int, title: String) -> some View {
        let selected = viewModel.literStepMilli == milli
        return Button {
            viewModel.literStepMilli = milli
        } label: {
            Text(title)
                .font(.caption.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(selected ? WatchTheme.violet : Color.primary.opacity(0.15), in: Capsule())
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
    }
}

private struct WatchCrownHint: View {
    var body: some View {
        Label("Gire a coroa", systemImage: "digitalcrown.horizontal.arrow.clockwise")
            .font(.caption2)
            .foregroundStyle(.secondary)
    }
}
