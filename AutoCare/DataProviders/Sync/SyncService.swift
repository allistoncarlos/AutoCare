//
//  SyncService.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 07/07/26.
//

import Factory
import Foundation

@MainActor
final class SyncService {
    @Injected(\.changesRepository) private var changesRepository
    @Injected(\.vehicleRepository) private var vehicleRepository
    @Injected(\.vehicleMileageRepository) private var vehicleMileageRepository
    @Injected(\.vehicleServiceRepository) private var vehicleServiceRepository

    private var ongoingSync: Task<Void, Never>?

    func sync() async {
        guard KeychainDataSource.hasValidToken() else { return }

        if let ongoingSync {
            await ongoingSync.value
            return
        }

        let task = Task { @MainActor in
            defer { self.ongoingSync = nil }

            await self.pushUnsyncedChanges()
            await self.pullRemoteChanges()

            SyncState.lastSyncRunAt = .now

            #if canImport(WatchConnectivity) && os(iOS)
            await WatchPhoneCoordinator.shared.pushVehiclesToWatch()
            #endif
        }

        ongoingSync = task
        await task.value
    }

    func pushUnsyncedChanges() async {
        do {
            let unsyncedEntities = try SwiftDataManager.shared.fetchUnsyncedEntities()

            for model in unsyncedEntities {
                if let vehicle = model as? Vehicle {
                    await vehicleRepository.save(vehicle: vehicle)
                    continue
                }

                if let mileage = model as? VehicleMileage {
                    await vehicleMileageRepository.save(vehicleMileage: mileage)
                    continue
                }

                if let service = model as? VehicleService {
                    await vehicleServiceRepository.save(vehicleService: service)
                }
            }
        } catch {
            print("Não foi possível enviar alterações locais: \(error)")
        }
    }

    func pullRemoteChanges() async {
        guard let response = await changesRepository.fetchChanges(since: SyncState.lastServerSyncAt) else {
            return
        }

        do {
            try SwiftDataManager.shared.applyRemoteChanges(response.changes)

            if let serverTime = ISO8601DateFormatter.parseSyncDate(response.serverTime) {
                SyncState.lastServerSyncAt = serverTime
            }
        } catch {
            print("Não foi possível aplicar alterações remotas: \(error)")
        }
    }
}

private extension ISO8601DateFormatter {
    static func parseSyncDate(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: value) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: value)
    }
}
