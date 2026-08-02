//
//  CarPlayFuelService.swift
//  AutoCare
//

import Factory
import Foundation

#if canImport(CarPlay)
/// Serviço de domínio usado pelo CarPlay para listar veículos e salvar abastecimentos.
@MainActor
final class CarPlayFuelService {
    @Injected(\.vehicleRepository) private var vehicleRepository
    @Injected(\.vehicleMileageRepository) private var mileageRepository

    var isAuthenticated: Bool {
        KeychainDataSource.hasValidToken()
    }

    func fetchVehicles() async -> [Vehicle] {
        let vehicles = await vehicleRepository.fetchData() ?? []
        return vehicles.filter { !$0.deleted }
    }

    func defaultVehicle(from vehicles: [Vehicle]) -> Vehicle? {
        vehicles.first(where: \.isDefault) ?? vehicles.first
    }

    func makeDraft(for vehicle: Vehicle) async -> CarPlayFuelDraft {
        let previous = await latestMileage(for: vehicle.referenceId)
        let previousOdometer = previous?.odometer ?? vehicle.odometer
        let previousFuelCost = previous?.fuelCost ?? Decimal(string: "5.99") ?? 5.99
        let previousTotalCost = previous?.totalCost ?? Decimal(200)

        return CarPlayFuelDraft(
            vehicleId: vehicle.referenceId,
            vehicleName: vehicle.name,
            previousOdometer: previousOdometer,
            odometer: max(previousOdometer + 1, vehicle.odometer),
            totalCost: previousTotalCost,
            fuelCost: previousFuelCost,
            complete: true
        )
    }

    func recentMileages(for vehicle: Vehicle, limit: Int = 5) async -> [VehicleMileage] {
        let mileages = await mileageRepository.fetchData(vehicleId: vehicle.referenceId) ?? []
        return Array(mileages.prefix(limit))
    }

    @discardableResult
    func save(draft: CarPlayFuelDraft) async -> VehicleMileage? {
        guard draft.isValid else { return nil }

        let mileage = VehicleMileage(
            id: nil,
            date: Date(),
            totalCost: draft.totalCost,
            odometer: draft.odometer,
            odometerDifference: draft.odometerDifference,
            liters: draft.liters,
            fuelCost: draft.fuelCost,
            calculatedMileage: draft.calculatedMileage,
            complete: draft.complete,
            vehicleId: draft.vehicleId
        )

        return await mileageRepository.save(vehicleMileage: mileage)
    }

    private func latestMileage(for vehicleId: String) async -> VehicleMileage? {
        await mileageRepository.fetchData(vehicleId: vehicleId)?.first
    }
}
#endif
