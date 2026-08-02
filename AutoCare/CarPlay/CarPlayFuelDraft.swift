//
//  CarPlayFuelDraft.swift
//  AutoCare
//

import Foundation

#if canImport(CarPlay)
/// Rascunho de abastecimento ajustável na central do carro (sem teclado).
struct CarPlayFuelDraft {
    var vehicleId: String
    var vehicleName: String
    var previousOdometer: Int
    var odometer: Int
    var totalCost: Decimal
    var fuelCost: Decimal
    var complete: Bool = true

    var liters: Decimal {
        guard fuelCost > 0 else { return 0 }
        return (totalCost / fuelCost).roundedDecimal(places: 3)
    }

    var odometerDifference: Int {
        max(0, odometer - previousOdometer)
    }

    var calculatedMileage: Decimal {
        guard liters > 0 else { return 0 }
        return (Decimal(odometerDifference) / liters).roundedDecimal(places: 2)
    }

    var isValid: Bool {
        odometer > previousOdometer && totalCost > 0 && fuelCost > 0 && liters > 0
    }

    mutating func adjustOdometer(by delta: Int) {
        odometer = max(previousOdometer, odometer + delta)
    }

    mutating func adjustTotalCost(by delta: Decimal) {
        totalCost = max(0, (totalCost + delta).roundedDecimal(places: 2))
    }

    mutating func adjustFuelCost(by delta: Decimal) {
        let minimum = Decimal(string: "0.01") ?? 0.01
        fuelCost = max(minimum, (fuelCost + delta).roundedDecimal(places: 2))
    }
}
#endif
