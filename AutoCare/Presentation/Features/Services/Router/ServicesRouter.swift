//
//  ServicesRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/06/25.
//

import SwiftUI

@MainActor
enum ServicesRouter {
    static func makeEditServiceView(
        navigationPath: Binding<NavigationPath>,
        vehicleId: String,
        serviceClientId: String?
    ) -> some View {
        let viewModel = ServiceEditView.ViewModel(
            serviceClientId: serviceClientId,
            vehicleId: vehicleId
        )

        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.maximumFractionDigits = 2

        let integerFormatter = NumberFormatter()
        integerFormatter.numberStyle = .none
        integerFormatter.maximumFractionDigits = 0

        return ServiceEditView(
            viewModel: viewModel,
            navigationPath: navigationPath,
            currencyFormatter: currencyFormatter,
            integerFormatter: integerFormatter
        )
        .id(serviceClientId ?? "new")
    }

    static func goBackToServices(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }
}
