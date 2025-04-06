//
//  AutoCareViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 04/04/25.
//

import Foundation
import SwiftUICore
import BackgroundTasks
import UserNotifications
import Factory

extension AutoCareApp {
    @MainActor
    class ViewModel: ObservableObject {
        @Injected(\.vehicleRepository) private var vehicleRepository: VehicleRepositoryProtocol
        @Injected(\.vehicleMileageRepository) private var vehicleMileageRepository: VehicleMileageRepositoryProtocol
        
        func resultView() -> AnyView {
            return KeychainDataSource.hasValidToken() ?
            AnyView(LoginRouter.makeHomeView(modelContext: SwiftDataManager.shared.container.mainContext)) :
                AnyView(LoginRouter.makeLoginView())
        }
        
        func scheduleAppSync() async {
    //        let today = Calendar.current.startOfDay (for: .now)
    //        let tomorrow = Calendar.current.date(byAdding: .day, value: 0, to: today)!
    //        let noonComponent = DateComponents(hour: 9, minute: 10)
    //        let noon = Calendar.current.date(byAdding: noonComponent, to: tomorrow)
    //        let request = BGAppRefreshTaskRequest(identifier: AutoCareApp.syncTask)
    //        request.earliestBeginDate = noon
    //        try? BGTaskScheduler.shared.submit(request)
            let startDate = Date()
            let calendar = Calendar.autoupdatingCurrent
            let checkTime = calendar.date(byAdding: .minute, value: 2, to: startDate)!
            print(checkTime)
            
            let notifyrequest = BGAppRefreshTaskRequest(identifier: AutoCareApp.syncTask)
            notifyrequest.earliestBeginDate = checkTime
            try? BGTaskScheduler.shared.submit(notifyrequest)
            print("Done Scheduling")
        }
        
        func requestAuthorizationForNotifications() async throws -> Bool {
            // 2. Get the shared instance of UNUserNotificationCenter
            let notificationCenter = UNUserNotificationCenter.current()
            // 3. Define the types of authorization you need
            let authorizationOptions: UNAuthorizationOptions = [.alert, .sound]

            do {
                // 4. Request authorization to the user
                let authorizationGranted = try await notificationCenter.requestAuthorization(options: authorizationOptions)
                // 5. Return the result of the authorization process
                return authorizationGranted
            } catch {
                throw error
            }
        }
        
        func photoUploadNotification() -> UNNotificationRequest {
            let content = UNMutableNotificationContent()
            content.title = "Sync executado"
            content.body = "A data foi \(Date.now)"
            content.categoryIdentifier = "alarm"
            content.userInfo = ["customData": "fizzbuzz"]
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            return request
        }
        
        func notifySyncCompleted() async {
            let notificationRequest = photoUploadNotification()
            do {
                try await UNUserNotificationCenter.current().add(notificationRequest)
            }
            catch {
                print("Notification failed with error: \(String(describing: error))")
            }
        }
        
        func syncData() async {
            do {
                let unsyncedEntities = try SwiftDataManager.shared.fetchUnsyncedEntities()
                
                for model in unsyncedEntities {
                    if let vehicleMileage = model as? VehicleMileage {
                        await vehicleMileageRepository.save(id: nil, vehicleMileage: vehicleMileage)
                    }
                    
                    if let vehicle = model as? Vehicle {
                        await vehicleRepository.save(id: nil, vehicle: vehicle)
                    }
                }
                
                await notifySyncCompleted()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
