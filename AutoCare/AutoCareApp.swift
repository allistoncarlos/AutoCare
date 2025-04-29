//
//  AutoCareApp.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 27/10/23.
//

import SwiftUI
import TTProgressHUD
import BackgroundTasks

@main
struct AutoCareApp: SwiftUI.App {
    static let dateTimeFormat = "dd/MM/yyyy HH:mm"
    static let dateFormat = "dd/MM/yyyy"
    static let shortDateFormat = "dd/MM"
    static let timeFormat = "HH:mm"
    
    static let syncTask = "AutoCare.SyncTask"
    
    static let hudConfig = TTProgressHUDConfig(
        title: "Carregando",
        caption: "Por favor aguarde..."
    )
    
    @ObservedObject var viewModel = AutoCareApp.ViewModel()

    var body: some Scene {
        WindowGroup {
            viewModel.resultView()
                .task {
                    await viewModel.syncData()
                    await viewModel.scheduleAppSync()
                    
                    if await !SwiftDataManager.shared.hasFetchedInitialData {
                        await viewModel.fetchRemote()
                    }
                    
                    do {
                        if try await viewModel.requestAuthorizationForNotifications() {
                            await viewModel.notifySyncCompleted()
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    // TODO: https://stackoverflow.com/questions/77494254/background-task-backgroundtask-doesnt-work-in-swiftui
                    // e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"SyncTask"]
                    
                    // TODO: VER ONDE PEÇO PERMISSÃO PRA NOTIFICATION (É SÓ TESTE)
                }
        }
        .modelContainer(SwiftDataManager.shared.container)
        .backgroundTask(.appRefresh(AutoCareApp.syncTask)) {
            await viewModel.scheduleAppSync()
            
            await viewModel.syncData()
            await viewModel.fetchRemote()
            
            
            
            // https://www.youtube.com/watch?v=JDw4Cs1Hbpo
            // TODO: VERIFICAR AQUI SE PRECISA DE PERMISSÃO PRA BACKGROUND TASK
            // TODO: FAZER AQUI A CHAMADA PRO SAVE DE CADA REPOSITORY
            // TODO: SALVAR EM ALGUM LUGAR O TIMESTAMP, ACHO QUE EM USERDEFAULTS (Ver o que fazer com esse TIMESTAMP)
        }
    }
}
