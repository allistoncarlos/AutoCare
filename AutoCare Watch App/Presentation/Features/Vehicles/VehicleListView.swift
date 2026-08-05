//
//  VehicleListView.swift
//  AutoCare Watch App
//

import SwiftUI

struct VehicleListView: View {
    let vehicles: [WatchVehicle]
    let lastSelectedVehicleId: String?

    private var orderedVehicles: [WatchVehicle] {
        guard let lastSelectedVehicleId,
              let index = vehicles.firstIndex(where: { $0.id == lastSelectedVehicleId }) else {
            return vehicles
        }

        var ordered = vehicles
        let selected = ordered.remove(at: index)
        ordered.insert(selected, at: 0)
        return ordered
    }

    var body: some View {
        List(orderedVehicles) { vehicle in
            NavigationLink(value: vehicle.id) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(vehicle.name)
                            .font(.headline)

                        if vehicle.isDefault {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                        }

                        if vehicle.id == lastSelectedVehicleId {
                            Text("Recente")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let odometer = vehicle.lastOdometer {
                        Text("\(odometer) km")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
