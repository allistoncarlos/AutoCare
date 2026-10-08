//
//  FuelAmountKeypadView.swift
//  AutoCare Watch App
//

import SwiftUI

struct FuelAmountKeypadView: View {
    @ObservedObject var viewModel: MileageFormViewModel
    let onContinue: () -> Void

    private let maxCents = 200_000

    var body: some View {
        WatchMaquininhaKeypad(
            rawValue: $viewModel.totalCostCents,
            maxRaw: maxCents,
            display: viewModel.totalCostLabel,
            caption: "valor da bomba",
            progressIndex: 0,
            navigationTitle: "Valor",
            canContinue: viewModel.canContinueAmount,
            onContinue: onContinue
        )
        .onAppear { viewModel.step = .amount }
    }
}
