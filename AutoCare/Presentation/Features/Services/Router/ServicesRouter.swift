//
//  ServicesRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/06/25.
//

import Foundation
import SwiftUI
import SwiftData

enum ServicesRouter {
    static func makeEditServiceView(
        navigationPath: Binding<NavigationPath>,
        modelContainer: ModelContainer,
        vehicleId: String,
        vehicleService: VehicleService?
    ) -> some View {
        // Por enquanto, retorna uma view simples até que a ServiceEditView seja implementada
        return Text("Editar Serviço - Em desenvolvimento")
            .navigationTitle("Editar Serviço")
    }

    static func goBackToServices(navigationPath: Binding<NavigationPath>) {
        navigationPath.wrappedValue.removeLast()
    }
}

