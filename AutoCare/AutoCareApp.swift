//
//  AutoCareApp.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 27/10/23.
//

import SwiftData
import SwiftUI
import TTProgressHUD

@main
struct AutoCareApp: App {
    static let dateTimeFormat = "dd/MM/yyyy HH:mm"
    static let dateFormat = "dd/MM/yyyy"
    static let shortDateFormat = "dd/MM"
    static let timeFormat = "HH:mm"

    static let hudConfig = TTProgressHUDConfig(
        title: "Carregando",
        caption: "Por favor aguarde..."
    )

    @ObservedObject private var viewModel = ViewModel()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            VehicleType.self,
            Vehicle.self,
            VehicleMileage.self,
            VehicleService.self
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
            viewModel.resultView(modelContext: sharedModelContainer.mainContext)
        }
        .modelContainer(sharedModelContainer)
    }
}
