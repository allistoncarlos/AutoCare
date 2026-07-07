//
//  HomeViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 13/02/25.
//

import Combine
import Factory
import Foundation
import SwiftData
import SwiftUI

extension HomeView {
    @MainActor
    final class ViewModel: ObservableObject {
        @Published private(set) var state: HomeState = .idle
        @Published private(set) var selectedVehicle: Vehicle?

        let modelContext: ModelContext

        @Injected(\.vehicleRepository) private var vehicleRepository

        init(modelContext: ModelContext) {
            self.modelContext = modelContext
        }

        func showEditVehicleView(
            vehicleId: String?,
            isPresented: Binding<Bool>
        ) -> some View {
            HomeRouter.makeEditVehicleView(
                modelContext: modelContext,
                vehicleId: vehicleId,
                isPresented: isPresented
            )
        }

        func showPulseUI() -> some View {
            HomeRouter.makePulseUI()
        }

        func fetchData() async {
            state = .loading

            guard let vehicles = await vehicleRepository.fetchData() else {
                state = .error
                return
            }

            cacheVehicles(vehicles)
            state = vehicles.isEmpty ? .newVehicle : .successVehicle(vehicles)

            if vehicles.isEmpty {
                selectedVehicle = nil
            } else if selectedVehicle == nil {
                selectedVehicle = vehicles.first(where: \.isDefault) ?? vehicles.first
            }
        }

        @discardableResult
        func requestAuthorizationForNotifications() async -> Bool {
            let notificationCenter = UNUserNotificationCenter.current()
            let authorizationOptions: UNAuthorizationOptions = [.alert, .sound]

            do {
                return try await notificationCenter.requestAuthorization(options: authorizationOptions)
            } catch {
                print(error)
                return false
            }
        }

        private func cacheVehicles(_ vehicles: [Vehicle]) {
            do {
                try modelContext.delete(model: Vehicle.self)
                vehicles.forEach { modelContext.insert($0) }
                try modelContext.save()
            } catch {
                print(error)
            }
        }
    }
}
