//
//  CarPlayFuelDraft.swift
//  AutoCare
//

import Foundation

#if canImport(CarPlay)
/// Rascunho de abastecimento preenchido via teclado numérico no CarPlay.
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

    mutating func applyOdometer(_ buffer: CarPlayNumericBuffer) {
        guard let value = buffer.integerValue else { return }
        odometer = max(previousOdometer, value)
    }

    mutating func applyTotalCost(_ buffer: CarPlayNumericBuffer) {
        guard let value = buffer.decimalValue else { return }
        totalCost = max(0, value)
    }

    mutating func applyFuelCost(_ buffer: CarPlayNumericBuffer) {
        guard let value = buffer.decimalValue, value > 0 else { return }
        fuelCost = value
    }
}
#endif
