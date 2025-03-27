//
//  MileagesRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 17/03/24.
//

import Foundation
import SwiftUI
import RealmSwift

@MainActor
enum MileagesRouter {
    static func makeEditVehicleView(
        realm: Realm,
        vehicleId: String?,
        isPresented: Binding<Bool>
    ) -> some View {
        return VehicleEditView(
            viewModel: VehicleEditView.ViewModel(
                vehicleId: vehicleId,
                realm: realm
            ),
            isPresented: isPresented
        )
        .interactiveDismissDisabled()
    }
    
    static func makeEditMileageView(
        navigationPath: Binding<NavigationPath>,
        realm: Realm,
        userId: String,
        vehicleId: String,
        vehicleMileage: VehicleMileage?
    ) -> some View {
        let viewModel = MileageEditView.ViewModel(
            realm: realm,
            vehicleMileage: vehicleMileage,
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
    }

    static func goBackToMileages(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }
}
