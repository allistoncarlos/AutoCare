//
//  AutoCareApp.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 27/10/23.
//

import SwiftUI
import TTProgressHUD

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

    var body: some Scene {
        WindowGroup {
            resultView()
        }
        .modelContainer(SwiftDataManager.shared.container)
    }
    
    @MainActor
    private func resultView() -> AnyView {
        return KeychainDataSource.hasValidToken() ?
        AnyView(LoginRouter.makeHomeView(modelContext: SwiftDataManager.shared.container.mainContext)) :
            AnyView(LoginRouter.makeLoginView())
    }
}
