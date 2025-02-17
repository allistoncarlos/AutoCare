//
//  AutoCareApp.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 27/10/23.
//

import SwiftUI
import RealmSwift
import TTProgressHUD
import SwiftData

@main
struct AutoCareApp: SwiftUI.App {
    static var app = App(id: Config.appId)
    
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
            VehicleData.self,
            VehicleMileageData.self
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
            resultView()
                .environmentObject(AutoCareApp.app)
        }
        .modelContainer(sharedModelContainer)
    }
    
    @MainActor
    private func resultView() -> AnyView {
        guard let currentUser = AutoCareApp.app.currentUser else {
            return AnyView(LoginRouter.makeLoginView())
        }
        
        return currentUser.isLoggedIn ?
            AnyView(LoginRouter.makeHomeView()) :
            AnyView(LoginRouter.makeLoginView())
    }
}
