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

    static func goBackToGames(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }
}
