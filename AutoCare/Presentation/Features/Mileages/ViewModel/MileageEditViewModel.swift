//
//  MileageEditViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 11/04/24.
//

import Foundation
import SwiftUI
import Combine
import FormValidator
import SwiftData
import Factory

extension MileageEditView {
    class ViewModel: ObservableObject {
        @Published var state: MileageEditState = .idle
        @Published var vehicleMileage: VehicleMileage?
        
        var previousMileage: VehicleMileage?
        
        private var cancellable = Set<AnyCancellable>()
        private var modelContainer: ModelContainer
        private var vehicleId: String
        
        @Published var isFormValid = false
        
        @Published var manager = FormManager(validationType: .immediate)
        
        @Injected(\.vehicleMileageRepository) private var repository: VehicleMileageRepositoryProtocol
        
        // MARK: - Form Fields
        @FormField(validator: DateValidator(message: "Informe uma data válida"))
        var date: Date = Date()
        
        @FormField(validator: NonEmptyValidator(message: "Informe o custo total"))
        var totalCost: String = ""
        
        var odometer: String?
        var liters: Decimal?
        var fuelCost: String?
        var complete: Bool = true
        
        @Published var odometerDifference: Int?
        
        // MARK: - Validations
        lazy var dateValidation = _date.validation(manager: manager)
        lazy var totalCostValidation = _totalCost.validation(manager: manager)
        
        init(
            modelContainer: ModelContainer,
            vehicleMileage: VehicleMileage?,
            vehicleId: String
        ) {
            self.modelContainer = modelContainer
            self.vehicleMileage = vehicleMileage
            self.vehicleId = vehicleId
            
            $state
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    switch state {
                    case let .successPreviousMileage(previousMileage):
                        self?.previousMileage = previousMileage
                    default:
                        break
                    }
                }.store(in: &cancellable)
        }
        
        func updateOdometerDifference() {
            if let odometer, let intOdometer = Int(odometer), let previousMileage {
                self.odometerDifference = intOdometer - previousMileage.odometer
            }
        }
        
        func calculateMileage() -> Decimal? {
            // Diferença de quilometragem, pela litragem
            if let odometerDifference = odometerDifference, let liters = liters {
                let calculatedMileage = Decimal(odometerDifference) / liters
                let roundedMileage = calculatedMileage.roundedDecimal(places: 2)
                return roundedMileage
            }
            
            return nil
        }
        
        func fetchPreviousVehicleMileage() async {
            do {
                state = .loading
                
                let descriptor = FetchDescriptor<VehicleMileage>(
                    sortBy: [SortDescriptor(\.date, order: .reverse)]
                )

                let result = try modelContext.fetch(descriptor)
                let result = try await modelContainer.mainContext.fetch(descriptor)
                var lastVehicleMileage: VehicleMileage? = nil
                
                if let vehicleMileage {
                    let index = result.lastIndex(where: { $0.id == vehicleMileage.id })

                    if let index, index < result.count - 1 {
                        lastVehicleMileage = result[index + 1]
                    }
                } else {
                    lastVehicleMileage = result
                        .sorted { $0.date > $1.date }
                        .first(where: { $0.vehicleId == vehicleId })
                }
                
                state = .successPreviousMileage(lastVehicleMileage)
            } catch {
                print(error)
                state = .error
            }
        }
        
        func save(isConnected: Bool) async {
            if manager.triggerValidation() {
                state = .loading
                
                let calculatedMileage = calculateMileage() ?? 0
                    
                guard
                    let odometer,
                    let odometer = Int(odometer),
                    let liters,
                    let fuelCost,
                    let fuelCost = Decimal(string: fuelCost)
                else {
                    state = .error
                    return
                }
                
                let resultVehicleMileage = vehicleMileage ?? VehicleMileage(
                    id: nil,
                    date: date,
                    totalCost: Decimal(string: totalCost)!,
                    odometer: odometer,
                    odometerDifference: odometerDifference ?? 0,
                    liters: liters,
                    fuelCost: fuelCost,
                    calculatedMileage: calculatedMileage,
                    complete: complete,
                    vehicleId: vehicleId
                )

                await SwiftDataManager.shared.save(item: resultVehicleMileage)
                
                state = .successSave
            }
        }
        
        private func saveRemote(id: String? = nil, vehicleMileage: VehicleMileage) async {
            let result = await repository.save(id: id, vehicleMileage: vehicleMileage)

            if result != nil {
                state = .successSave
            } else {
                state = .error
            }
        }
        
        private func saveLocal(id: String? = nil, vehicleMileage: VehicleMileage) async {
            do {
                if let id {
                    try await update(id: id, vehicleMileage: vehicleMileage)
                } else {
                    try await insert(vehicleMileage: vehicleMileage)
                }
                
                state = .successSave
            } catch {
                print(error.localizedDescription)
                state = .error
            }
        }
        
        private func update(id: String, vehicleMileage: VehicleMileage) async throws {
            let descriptor = createUpdateDescriptor(for: id)
            
            // TODO: ORGANIZAR ISSO AQUI, DE ACORDO COM HOMEVIEWMODEL/ACTOR/STATESTORE
            let result = try await modelContainer.mainContext.fetch(descriptor)
            
            if result.count == 1, let vehicleMileageResult = result.first {
                vehicleMileageResult.synced = false
                try await modelContainer.mainContext.save()
                state = .successSave
            } else {
                state = .error
            }
        }
        
        private func insert(vehicleMileage: VehicleMileage) async throws {
            // TODO: ORGANIZAR ISSO AQUI, DE ACORDO COM HOMEVIEWMODEL/ACTOR/STATESTORE
            await modelContainer.mainContext.insert(vehicleMileage)
            try await modelContainer.mainContext.save()
            
            state = .successSave
        }
        
        private func createUpdateDescriptor(for id: String) -> FetchDescriptor<Vehicle> {
            var descriptor = FetchDescriptor<Vehicle>(predicate: #Predicate { vehicle in
                vehicle.id == id
            })
            
            descriptor.fetchLimit = 1
            
            return descriptor
        }
    }
}

#if os(iOS)
extension MileageEditView.ViewModel {
    func goBackToMileages(navigationPath: Binding<NavigationPath>) {
        MileagesRouter.goBackToMileages(navigationPath: navigationPath)
    }
}
#endif
