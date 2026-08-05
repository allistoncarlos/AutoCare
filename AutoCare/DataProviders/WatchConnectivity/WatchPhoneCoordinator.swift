//
//  WatchPhoneCoordinator.swift
//  AutoCare
//

#if os(iOS) && canImport(WatchConnectivity)
import Factory
import Foundation
import WatchConnectivity

@MainActor
final class WatchPhoneCoordinator {
    static let shared = WatchPhoneCoordinator()

    @Injected(\.vehicleRepository) private var vehicleRepository
    @Injected(\.vehicleMileageRepository) private var mileageRepository
    @Injected(\.swiftDataManager) private var swiftDataManager

    func handle(message: [String: Any]) async -> [String: Any] {
        if message[WatchMessageKey.checkAuth] != nil {
            return handleCheckAuth()
        }

        if message[WatchMessageKey.fetchVehicles] != nil {
            return await handleFetchVehicles()
        }

        if let data = message[WatchMessageKey.saveMileage] as? Data,
           let request = WatchConnectivityPayloadCodec.decode(WatchSaveMileageRequest.self, from: data) {
            return await handleSaveMileage(request)
        }

        return [WatchMessageKey.error: "unknown_message"]
    }

    func pushVehiclesToWatch() async {
        guard WCSession.default.activationState == .activated,
              WCSession.default.isPaired,
              WCSession.default.isWatchAppInstalled else {
            return
        }

        let authStatus: WatchAuthStatus = KeychainDataSource.hasValidToken() ? .logged : .notLogged

        guard authStatus == .logged else {
            pushContext(vehicles: [], authStatus: .notLogged)
            return
        }

        let vehicles = await loadVehicles()
        pushContext(vehicles: vehicles, authStatus: .logged)
    }

    // MARK: Private

    private func handleCheckAuth() -> [String: Any] {
        let status: WatchAuthStatus = KeychainDataSource.hasValidToken() ? .logged : .notLogged
        return [WatchMessageKey.authStatus: status.rawValue]
    }

    private func handleFetchVehicles() async -> [String: Any] {
        guard KeychainDataSource.hasValidToken() else {
            pushContext(vehicles: [], authStatus: .notLogged)
            return [WatchMessageKey.authStatus: WatchAuthStatus.notLogged.rawValue]
        }

        let vehicles = await loadVehicles()
        pushContext(vehicles: vehicles, authStatus: .logged)

        guard let data = WatchConnectivityPayloadCodec.encode(WatchVehiclesPayload(vehicles: vehicles)) else {
            return [WatchMessageKey.error: "encode_failed"]
        }

        return [WatchMessageKey.vehicles: data]
    }

    private func handleSaveMileage(_ request: WatchSaveMileageRequest) async -> [String: Any] {
        guard KeychainDataSource.hasValidToken() else {
            pushContext(vehicles: [], authStatus: .notLogged)
            return [WatchMessageKey.authStatus: WatchAuthStatus.notLogged.rawValue]
        }

        let date: Date
        if let dateISO = request.dateISO,
           let parsed = WatchConnectivityDateCodec.date(fromISO: dateISO) {
            date = parsed
        } else {
            date = Date()
        }

        let previousMileage = await fetchPreviousMileage(vehicleId: request.vehicleId)
        let odometerDifference = max(0, request.odometer - (previousMileage?.odometer ?? request.odometer))
        let liters = Decimal(request.liters)
        let calculatedMileage: Decimal
        if liters > 0, odometerDifference > 0 {
            calculatedMileage = (Decimal(odometerDifference) / liters).roundedDecimal(places: 2)
        } else {
            calculatedMileage = 0
        }

        let mileage = VehicleMileage(
            id: nil,
            date: date,
            totalCost: Decimal(request.totalCost),
            odometer: request.odometer,
            odometerDifference: odometerDifference,
            liters: liters,
            fuelCost: Decimal(request.fuelCost),
            calculatedMileage: calculatedMileage,
            complete: request.complete,
            vehicleId: request.vehicleId
        )

        guard await mileageRepository.save(vehicleMileage: mileage) != nil else {
            return [WatchMessageKey.error: "save_failed"]
        }

        let vehicles = await loadVehicles()
        pushContext(vehicles: vehicles, authStatus: .logged)

        let payload = WatchMileageSavedPayload(
            success: true,
            odometerDifference: odometerDifference,
            calculatedMileage: NSDecimalNumber(decimal: calculatedMileage).doubleValue
        )

        return WatchConnectivityPayloadCodec.reply(WatchMessageKey.mileageSaved, value: payload)
            ?? [WatchMessageKey.error: "encode_failed"]
    }

    private func loadVehicles() async -> [WatchVehicle] {
        guard let vehicles = await vehicleRepository.fetchData() else { return [] }

        let active = vehicles.filter { !$0.deleted }
        var result: [WatchVehicle] = []

        for vehicle in active {
            let vehicleId = vehicle.referenceId
            let lastMileage = await fetchPreviousMileage(vehicleId: vehicleId)

            result.append(
                WatchVehicle(
                    id: vehicleId,
                    name: vehicle.name,
                    isDefault: vehicle.isDefault,
                    lastOdometer: lastMileage?.odometer ?? vehicle.odometer,
                    lastFuelCost: lastMileage.map { NSDecimalNumber(decimal: $0.fuelCost).doubleValue },
                    lastTotalCost: lastMileage.map { NSDecimalNumber(decimal: $0.totalCost).doubleValue },
                    lastLiters: lastMileage.map { NSDecimalNumber(decimal: $0.liters).doubleValue }
                )
            )
        }

        return result.sorted { lhs, rhs in
            if lhs.isDefault != rhs.isDefault {
                return lhs.isDefault && !rhs.isDefault
            }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    private func fetchPreviousMileage(vehicleId: String) async -> VehicleMileage? {
        do {
            let mileages: [VehicleMileage] = try await swiftDataManager.fetch(
                where: #Predicate<VehicleMileage> { mileage in
                    mileage.vehicleId == vehicleId && !mileage.deleted
                },
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            return mileages.first
        } catch {
            return nil
        }
    }

    private func pushContext(vehicles: [WatchVehicle], authStatus: WatchAuthStatus) {
        guard WCSession.default.activationState == .activated,
              let vehiclesData = WatchConnectivityPayloadCodec.encode(WatchVehiclesPayload(vehicles: vehicles)) else {
            return
        }

        let context: [String: Any] = [
            WatchMessageKey.authStatus: authStatus.rawValue,
            WatchMessageKey.vehicles: vehiclesData
        ]

        try? WCSession.default.updateApplicationContext(context)
    }
}
#endif
