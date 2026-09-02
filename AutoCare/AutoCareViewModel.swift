//
//  AutoCareViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 04/04/25.
//

import BackgroundTasks
import Factory
import Foundation
import SwiftUI

extension AutoCareApp {
    @MainActor
    final class ViewModel: ObservableObject {
        @Injected(\.syncService) private var syncService

        func scheduleAppSync() async {
            let calendar = Calendar.autoupdatingCurrent
            let checkTime = calendar.date(byAdding: .minute, value: 2, to: Date())!

            let request = BGAppRefreshTaskRequest(identifier: AutoCareApp.syncTask)
            request.earliestBeginDate = checkTime
            try? BGTaskScheduler.shared.submit(request)
        }

        func syncData() async {
            guard KeychainDataSource.hasValidToken() else { return }
            await syncService.sync()
        }
    }
}
