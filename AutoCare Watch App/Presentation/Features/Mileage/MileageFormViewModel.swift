//
//  MileageFormViewModel.swift
//  AutoCare Watch App
//

import Foundation
import WatchKit

enum FuelLogStep: Equatable {
    case amount
    case price
    case odometer
    case confirm
    case liters
    case success
}

enum MileageFormUIState: Equatable {
    case editing
    case saving
    case success(odometerDifference: Int, calculatedMileage: Double)
    case error(String)
}

@MainActor
final class MileageFormViewModel: ObservableObject {
    let vehicle: WatchVehicle

    /// Valores em centavos (R$ × 100).
    @Published var totalCostCents: Int = 0
    @Published var fuelCostCents: Int = 0
    /// Litros × 1000 (3 casas decimais).
    @Published var litersMilli: Int = 0
    @Published var odometer: Int = 0
    @Published var isComplete: Bool = true
    @Published var uiState: MileageFormUIState = .editing
    @Published var step: FuelLogStep = .amount
    @Published var priceStepCents: Int = 1
    @Published var odometerStep: Int = 100
    @Published var literStepMilli: Int = 100

    private let service = WatchMileageService()

    init(vehicle: WatchVehicle) {
        self.vehicle = vehicle

        if let lastFuelCost = vehicle.lastFuelCost {
            fuelCostCents = Self.cents(from: lastFuelCost)
        }

        if let lastOdometer = vehicle.lastOdometer {
            odometer = lastOdometer
        }
    }

    var canContinueAmount: Bool {
        totalCostCents > 0
    }

    var canContinuePrice: Bool {
        fuelCostCents > 0
    }

    var canContinueOdometer: Bool {
        if let lastOdometer = vehicle.lastOdometer {
            return odometer > lastOdometer
        }
        return odometer > 0
    }

    var canContinueLiters: Bool {
        litersMilli > 0
    }

    var canSave: Bool {
        let isIdle: Bool
        switch uiState {
        case .editing, .error:
            isIdle = true
        case .saving, .success:
            isIdle = false
        }

        return canContinueAmount
            && canContinuePrice
            && canContinueLiters
            && canContinueOdometer
            && isIdle
    }

    var totalCostLabel: String {
        WatchNumberFormatting.currency(cents: totalCostCents)
    }

    var fuelCostLabel: String {
        WatchNumberFormatting.currency(cents: fuelCostCents)
    }

    var lastFuelCostLabel: String? {
        guard let lastFuelCost = vehicle.lastFuelCost else { return nil }
        return WatchNumberFormatting.currency(cents: Self.cents(from: lastFuelCost))
    }

    var litersLabel: String {
        WatchNumberFormatting.liters(milliLiters: litersMilli)
    }

    var odometerLabel: String {
        WatchNumberFormatting.grouped(odometer)
    }

    var distanceKm: Int? {
        guard let lastOdometer = vehicle.lastOdometer else { return nil }
        let delta = odometer - lastOdometer
        return delta > 0 ? delta : nil
    }

    var priceStepLabel: String {
        priceStepCents == 1 ? "± R$ 0,01" : "± R$ 0,10"
    }

    var priceRange: ClosedRange<Int> {
        let upper = max(2_000, fuelCostCents)
        return 0...upper
    }

    var odometerRange: ClosedRange<Int> {
        let lower = max(vehicle.lastOdometer ?? 0, 0)
        let upper = max(lower + 5_000, odometer + 500)
        return lower...upper
    }

    var litersRange: ClosedRange<Int> {
        0...200_000
    }

    func togglePriceStep() {
        priceStepCents = priceStepCents == 1 ? 10 : 1
    }

    func toggleLiterStep() {
        literStepMilli = literStepMilli == 100 ? 1_000 : 100
    }

    func recalculateLitersIfNeeded() {
        guard isComplete, fuelCostCents > 0, totalCostCents > 0 else { return }

        let raw = (Double(totalCostCents) * 1_000.0) / Double(fuelCostCents)
        litersMilli = max(Int(raw.rounded()), 0)
    }

    func setComplete(_ complete: Bool) {
        isComplete = complete
        if complete {
            recalculateLitersIfNeeded()
        }
    }

    func save() async {
        if case .success = uiState { return }
        recalculateLitersIfNeeded()

        guard canSave else {
            uiState = .error("Preencha os campos")
            return
        }

        uiState = .saving

        let request = WatchSaveMileageRequest(
            vehicleId: vehicle.id,
            totalCost: Double(totalCostCents) / 100.0,
            fuelCost: Double(fuelCostCents) / 100.0,
            liters: Double(litersMilli) / 1_000.0,
            odometer: odometer,
            complete: isComplete,
            dateISO: WatchConnectivityDateCodec.isoString(from: Date())
        )

        do {
            let result = try await service.saveMileage(request)
            WKInterfaceDevice.current().play(.success)
            uiState = .success(
                odometerDifference: result.odometerDifference,
                calculatedMileage: result.calculatedMileage
            )
            step = .success
        } catch WatchMileageServiceError.notLogged {
            uiState = .error("Faça login no iPhone")
        } catch {
            uiState = .error(error.localizedDescription)
        }
    }

    private static func cents(from value: Double) -> Int {
        Int((value * 100.0).rounded())
    }
}
