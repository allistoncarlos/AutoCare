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
        @Injected(\.vehicleTypeRepository) private var vehicleTypeRepository: VehicleTypeRepositoryProtocol
        @Injected(\.vehicleRepository) private var vehicleRepository: VehicleRepositoryProtocol
        @Injected(\.vehicleMileageRepository) private var vehicleMileageRepository: VehicleMileageRepositoryProtocol
        
        func resultView() -> AnyView {
            return KeychainDataSource.hasValidToken() ?
                AnyView(LoginRouter.makeHomeView(modelContainer: SwiftDataManager.shared.container)) :
                AnyView(LoginRouter.makeLoginView(modelContainer: SwiftDataManager.shared.container))
        }
        
        func scheduleAppSync() async {
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
            let notificationCenter = UNUserNotificationCenter.current()
            let authorizationOptions: UNAuthorizationOptions = [.alert, .sound]

            do {
                let authorizationGranted = try await notificationCenter.requestAuthorization(options: authorizationOptions)
                return authorizationGranted
            } catch {
                throw error
            }
        }
        
        func photoUploadNotification() -> UNNotificationRequest {
            // TODO: ORGANIZAR A NOTIFICAÇÃO
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
                        await vehicleMileageRepository.save(id: vehicleMileage.id, vehicleMileage: vehicleMileage)
                    }
                    
                    if let vehicle = model as? Vehicle {
                        await vehicleRepository.save(id: vehicle.id, vehicle: vehicle)
                    }
                }
                
                await notifySyncCompleted()
            } catch {
                print(error)
            }
        }
        
        func fetchRemote() async {
            var vehicleTypes: [VehicleType] = []
            var vehicles: [Vehicle] = []
            
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    vehicleTypes = await self.vehicleTypeRepository.fetchData() ?? []
                }
                group.addTask {
                    vehicles = await self.vehicleRepository.fetchData() ?? []
                }
            }
            
            var vehicleMileages: [VehicleMileage] = await withTaskGroup(of: [VehicleMileage].self) { group in
                for vehicle in vehicles {
                    if let id = vehicle.id {
                        group.addTask {
                            return await self.vehicleMileageRepository.fetchData(vehicleId: id) ?? []
                        }
                    }
                }
                
                var collected: [VehicleMileage] = []
                for await result in group {
                    collected.append(contentsOf: result)
                }
                return collected
            }
            
            vehicleTypes = vehicleTypes.map { vehicleType in
                vehicleType.synced = true
                return vehicleType
            }
            
            vehicles = vehicles.map { vehicle in
                vehicle.synced = true
                return vehicle
            }
            
            vehicleMileages = vehicleMileages.map { vehicleMileage in
                vehicleMileage.synced = true
                return vehicleMileage
            }
            
            do {
                try await SwiftDataManager.shared.importData(vehicleTypes)
                try await SwiftDataManager.shared.importData(vehicles)
                try await SwiftDataManager.shared.importData(vehicleMileages)
            } catch {
                // TODO: FUTURAMENTE UMA TELA DE LOG DE SYNC, TIPO O SYNCTIME?
                print(error)
            }
        }
    }
}
