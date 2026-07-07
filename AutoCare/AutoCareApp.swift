//
//  AutoCareApp.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 27/10/23.
//

import BackgroundTasks
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

    @ObservedObject private var viewModel = ViewModel()

    var body: some Scene {
        WindowGroup {
            viewModel.resultView()
                .task {
                    await viewModel.syncData()
                    await viewModel.scheduleAppSync()
                }
        }
        .modelContainer(SwiftDataManager.shared.container)
        .backgroundTask(.appRefresh(AutoCareApp.syncTask)) {
            await viewModel.scheduleAppSync()
            await viewModel.syncData()
        }
    }
}
