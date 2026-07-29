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
import UserNotifications

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
            await notifySyncCompleted()
        }

        private func syncNotification() -> UNNotificationRequest {
            let content = UNMutableNotificationContent()
            content.title = "Sync executado"
            content.body = "A data foi \(Date.now)"
            content.categoryIdentifier = "alarm"
            content.sound = .default

            return UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        }

        private func notifySyncCompleted() async {
            do {
                try await UNUserNotificationCenter.current().add(syncNotification())
            } catch {
                print("Notification failed with error: \(String(describing: error))")
            }
        }
    }
}
