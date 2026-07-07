//
//  ServicesRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/06/25.
//

import SwiftUI

enum ServicesRouter {
    static func makeEditServiceView(
        navigationPath: Binding<NavigationPath>,
        vehicleId: String,
        vehicleService: VehicleService?
    ) -> some View {
        Text("Editar Serviço - Em desenvolvimento")
            .navigationTitle("Editar Serviço")
    }

    static func goBackToServices(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }
}
