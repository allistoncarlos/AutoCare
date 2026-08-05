//
//  MileageFormViewModel.swift
//  AutoCare Watch App
//

import Foundation

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

    private let service = WatchMileageService()

    init(vehicle: WatchVehicle) {
        self.vehicle = vehicle

        if let lastTotalCost = vehicle.lastTotalCost {
            totalCostCents = Self.cents(from: lastTotalCost)
        }

        if let lastFuelCost = vehicle.lastFuelCost {
            fuelCostCents = Self.cents(from: lastFuelCost)
        }

        if let lastOdometer = vehicle.lastOdometer {
            odometer = lastOdometer
        }

        if let lastLiters = vehicle.lastLiters {
            litersMilli = Self.milliLiters(from: lastLiters)
        }

        recalculateLitersIfNeeded()
    }

    var canSave: Bool {
        totalCostCents > 0
            && fuelCostCents > 0
            && litersMilli > 0
            && odometer > 0
            && uiState != .saving
    }

    var totalCostLabel: String {
        WatchNumberFormatting.currency(cents: totalCostCents)
    }

    var fuelCostLabel: String {
        WatchNumberFormatting.currency(cents: fuelCostCents)
    }

    var litersLabel: String {
        WatchNumberFormatting.liters(milliLiters: litersMilli)
    }

    var odometerLabel: String {
        "\(odometer) km"
    }

    var odometerRange: ClosedRange<Int> {
        let baseline = vehicle.lastOdometer ?? odometer
        let lower = max(0, baseline - 200)
        let upper = max(baseline + 2_000, odometer + 500, 1_000)
        return lower...upper
    }

    func recalculateLitersIfNeeded() {
        guard isComplete, fuelCostCents > 0, totalCostCents > 0 else { return }

        // litros = total / preço → milli = round(totalCents * 1000 / fuelCostCents)
        let raw = (Double(totalCostCents) * 1_000.0) / Double(fuelCostCents)
        litersMilli = max(Int(raw.rounded()), 0)
    }

    func save() async {
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
            uiState = .success(
                odometerDifference: result.odometerDifference,
                calculatedMileage: result.calculatedMileage
            )
        } catch WatchMileageServiceError.notLogged {
            uiState = .error("Faça login no iPhone")
        } catch {
            uiState = .error(error.localizedDescription)
        }
    }

    func resetAfterSuccess() {
        // Mantém custo total e preço/L do abastecimento recém-salvo.
        recalculateLitersIfNeeded()
        uiState = .editing
    }

    private static func cents(from value: Double) -> Int {
        Int((value * 100.0).rounded())
    }

    private static func milliLiters(from value: Double) -> Int {
        Int((value * 1_000.0).rounded())
    }
}
