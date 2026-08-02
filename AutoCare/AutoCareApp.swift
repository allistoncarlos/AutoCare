//
//  AutoCareApp.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 27/10/23.
//

import BackgroundTasks
import Factory
import SwiftData
import SwiftUI
import TTProgressHUD

@main
struct AutoCareApp: App {
    static let dateTimeFormat = "dd/MM/yyyy HH:mm"
    static let dateFormat = "dd/MM/yyyy"
    static let shortDateFormat = "dd/MM"
    static let timeFormat = "HH:mm"

    static let syncTask = "AutoCare.SyncTask"

    static let hudConfig = TTProgressHUDConfig(
        title: "Carregando",
        caption: "Por favor aguarde..."
    )

    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    @ObservedObject private var viewModel = ViewModel()
    @ObservedObject private var authSession = Container.shared.authSessionStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if authSession.isAuthenticated {
                    LoginRouter.makeHomeView()
                } else {
                    LoginRouter.makeLoginView()
                }
            }
            .brandTypography()
            .tint(BrandTheme.Colors.violetCore)
            .preferredColorScheme(.dark)
            .task {
                guard authSession.isAuthenticated else { return }
                await viewModel.scheduleAppSync()
            }
        }
        .modelContainer(SwiftDataManager.shared.container)
        .backgroundTask(.appRefresh(AutoCareApp.syncTask)) {
            guard KeychainDataSource.hasValidToken() else { return }
            await viewModel.scheduleAppSync()
            await viewModel.syncData()
        }
    }
}
