//
//  FuelKeypadStepsView.swift
//  AutoCare Watch App
//

import SwiftUI

struct FuelPriceStepView: View {
    @ObservedObject var viewModel: MileageFormViewModel
    let onContinue: () -> Void

    private let maxCents = 2_000

    var body: some View {
        WatchMaquininhaKeypad(
            rawValue: $viewModel.fuelCostCents,
            maxRaw: maxCents,
            display: viewModel.fuelCostLabel,
            caption: priceCaption,
            progressIndex: 1,
            navigationTitle: "Preço/L",
            canContinue: viewModel.canContinuePrice,
            onContinue: onContinue
        )
        .onAppear { viewModel.step = .price }
    }

    private var priceCaption: String {
        if let last = viewModel.lastFuelCostLabel {
            return "último: \(last)"
        }
        return "preço por litro"
    }
}

struct FuelOdometerStepView: View {
    @ObservedObject var viewModel: MileageFormViewModel
    let onContinue: () -> Void

    private let maxKm = 9_999_999

    var body: some View {
        WatchMaquininhaKeypad(
            rawValue: $viewModel.odometer,
            maxRaw: maxKm,
            display: viewModel.odometerLabel,
            caption: "quilometragem",
            progressIndex: 2,
            navigationTitle: "Odômetro",
            canContinue: viewModel.canContinueOdometer,
            onContinue: onContinue,
            footer: odometerFooter
        )
        .onAppear { viewModel.step = .odometer }
    }

    private var odometerFooter: AnyView? {
        guard let distanceKm = viewModel.distanceKm else { return nil }
        return AnyView(
            Text("+\(distanceKm) km")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(WatchTheme.success)
        )
    }
}

struct FuelLitersStepView: View {
    @ObservedObject var viewModel: MileageFormViewModel
    let onContinue: () -> Void

    private let maxMilli = 200_000

    var body: some View {
        WatchMaquininhaKeypad(
            rawValue: $viewModel.litersMilli,
            maxRaw: maxMilli,
            display: viewModel.litersLabel,
            caption: "litros abastecidos",
            progressIndex: nil,
            navigationTitle: "Litros",
            canContinue: viewModel.canContinueLiters,
            onContinue: onContinue
        )
        .onAppear { viewModel.step = .liters }
    }
}
