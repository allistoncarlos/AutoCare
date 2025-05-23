//
//  AutoCareApp.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 27/10/23.
//

import SwiftUI
import TTProgressHUD
import SwiftData

@main
struct AutoCareApp: SwiftUI.App {
    static let dateTimeFormat = "dd/MM/yyyy HH:mm"
    static let dateFormat = "dd/MM/yyyy"
    static let shortDateFormat = "dd/MM"
    static let timeFormat = "HH:mm"
    
    static let hudConfig = TTProgressHUDConfig(
        title: "Carregando",
        caption: "Por favor aguarde..."
    )
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            VehicleType.self,
            Vehicle.self,
            VehicleMileage.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            resultView(modelContext: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }
    
    @MainActor
    private func resultView(modelContext: ModelContext) -> AnyView {
        return KeychainDataSource.hasValidToken() ?
        AnyView(LoginRouter.makeHomeView(modelContext: modelContext)) :
            AnyView(LoginRouter.makeLoginView())
    }
}
