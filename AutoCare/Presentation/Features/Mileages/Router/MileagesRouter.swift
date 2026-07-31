//
//  MileagesRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 17/03/24.
//

import SwiftUI

@MainActor
enum MileagesRouter {
    static func makeEditMileageView(
        navigationPath: Binding<NavigationPath>,
        vehicleId: String,
        mileageClientId: String?
    ) -> some View {
        let viewModel = MileageEditView.ViewModel(
            mileageClientId: mileageClientId,
            vehicleId: vehicleId
        )

        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 2

        let decimalFormatter = NumberFormatter()
        decimalFormatter.numberStyle = .decimal
        decimalFormatter.maximumFractionDigits = 3
        decimalFormatter.minimumFractionDigits = 3
        decimalFormatter.currencySymbol = ""

        let integerFormatter = NumberFormatter()
        integerFormatter.numberStyle = .none
        integerFormatter.maximumFractionDigits = 0

        return MileageEditView(
            viewModel: viewModel,
            navigationPath: navigationPath,
            currencyFormatter: currencyFormatter,
            decimalFormatter: decimalFormatter,
            integerFormatter: integerFormatter
        )
        .id(mileageClientId ?? "new")
    }

    static func goBackToMileages(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }
}
