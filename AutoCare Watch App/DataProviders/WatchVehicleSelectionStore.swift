//
//  WatchVehicleSelectionStore.swift
//  AutoCare Watch App
//

import Foundation

enum WatchVehicleSelectionStore {
    private static let lastSelectedVehicleIdKey = "watch.lastSelectedVehicleId"

    static var lastSelectedVehicleId: String? {
        get { UserDefaults.standard.string(forKey: lastSelectedVehicleIdKey) }
        set {
            if let newValue, !newValue.isEmpty {
                UserDefaults.standard.set(newValue, forKey: lastSelectedVehicleIdKey)
            } else {
                UserDefaults.standard.removeObject(forKey: lastSelectedVehicleIdKey)
            }
        }
    }

    static func preferredVehicle(from vehicles: [WatchVehicle]) -> WatchVehicle? {
        guard !vehicles.isEmpty else { return nil }

        if vehicles.count == 1 {
            return vehicles[0]
        }

        if let lastId = lastSelectedVehicleId,
           let lastSelected = vehicles.first(where: { $0.id == lastId }) {
            return lastSelected
        }

        return nil
    }

    static func remember(_ vehicleId: String) {
        lastSelectedVehicleId = vehicleId
    }
}
