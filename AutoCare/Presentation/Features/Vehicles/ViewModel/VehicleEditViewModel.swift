//
//  VehicleEditViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 30/10/23.
//

import Foundation
import Combine
import FormValidator
import Factory
import SwiftData

extension VehicleEditView {
    @MainActor
    class ViewModel: ObservableObject {
        private var modelContext: ModelContext
        
        @Published var state: VehicleEditState = .idle
        @Published var vehicle: Vehicle?
        @Published var vehicleId: String? = nil
        @Published var vehicleTypes = [VehicleType]()
        @Published var isFormValid = false
        
        @Published private var manager = FormManager(validationType: .immediate)
        
        @Injected(\.vehicleRepository) private var repository: VehicleRepositoryProtocol
        @Injected(\.vehicleTypeRepository) private var vehicleTypeRepository: VehicleTypeRepositoryProtocol
        
        private var cancellable = Set<AnyCancellable>()
        
        @FormField(validator: NonEmptyValidator(message: "Selecione o Tipo do Veículo"))
        var selectedVehicleType: String = "" { didSet { self.triggerValidation()} }
        
        @FormField(validator: NonEmptyValidator(message: "Campo Nome obrigatório"))
        var name: String = "" { didSet { self.triggerValidation()} }
        
        @FormField(validator: NonEmptyValidator(message: "Campo Marca obrigatório"))
        var brand: String = "" { didSet { self.triggerValidation()} }
        
        @FormField(validator: NonEmptyValidator(message: "Campo Modelo obrigatório"))
        var model: String = "" { didSet { self.triggerValidation()} }
        
        @FormField(validator: NonEmptyValidator(message: "Campo Ano obrigatório"))
        var year: String = "" { didSet { self.triggerValidation()} }
        
        @FormField(validator: NonEmptyValidator(message: "Campo Placa obrigatório"))
        var licensePlate: String = "" { didSet { self.triggerValidation()} }
        
        @FormField(validator: NonEmptyValidator(message: "Campo Odômetro obrigatório"))
        var odometer: String = "" { didSet { self.triggerValidation()} }

        // MARK: - Validations
        lazy var nameValidation = _name.validation(manager: manager)
        lazy var selectedVehicleTypeValidation = _selectedVehicleType.validation(manager: manager)
        lazy var brandValidation = _brand.validation(manager: manager)
        lazy var modelValidation = _model.validation(manager: manager)
        lazy var yearValidation = _year.validation(manager: manager)
        lazy var licensePlateValidation = _licensePlate.validation(manager: manager)
        lazy var odometerValidation = _odometer.validation(manager: manager)
        
        // MARK: - Init
        init(
            modelContext: ModelContext,
            vehicleId: String?
        ) {
            self.modelContext = modelContext
            self.vehicleId = vehicleId
            
            $state
                .receive(on: RunLoop.main)
                .sink { [weak self] state in
                    switch state {
                    case let .successVehicleTypes(vehicleTypes):
                        self?.vehicleTypes = vehicleTypes
                    default:
                        break
                    }
                }.store(in: &cancellable)
        }
        
        func fetchData(isConnected: Bool) async {
            if isConnected {
                await fetchRemoteData()
            } else {
                fetchLocalData()
            }
        }
        
        private func fetchRemoteData() async {
            state = .loading

            let result = await vehicleTypeRepository.fetchData()
            
            if let result {
                state = .successVehicleTypes(result)
                
                self.syncData(result)
            } else {
                state = .error
            }
        }
        
        private func fetchLocalData() {
            do {
                state = .loading
                
                let descriptor = FetchDescriptor<VehicleType>(
                    sortBy: [SortDescriptor(\.name)]
                )

                let result = try modelContext.fetch(descriptor)
                
                state = .successVehicleTypes(result)
            } catch {
                state = .error
            }
        }
        
        private func syncData(_ vehicleTypes: [VehicleType]) {
            do {
                try modelContext.delete(model: VehicleType.self)
                
                vehicleTypes.forEach { vehicleType in
                    vehicleType.synced = true
                    modelContext.insert(vehicleType)
                }
                
                try modelContext.save()
                
                self.fetchLocalData()
            } catch {
                print(error)
            }
        }
        
        private func triggerValidation() {
            isFormValid = manager.triggerValidation()
        }

        func save(isConnected: Bool) async {
            isConnected ? await self.saveRemote() : self.saveLocal()
        }
        
        private func saveRemote() async {
            state = .loading

            if isFormValid {
                guard let odometer = Int(self.odometer) else { return }
                
                if vehicle == nil {
                    vehicle = Vehicle(
                        name: name,
                        brand: brand,
                        model: model,
                        year: year,
                        licensePlate: licensePlate,
                        odometer: odometer,
                        vehicleTypeId: selectedVehicleType
                    )
                }
                
                guard let vehicle else { return }

                let result = await repository.save(id: vehicle.id, vehicle: vehicle)

                if result != nil {
                    state = .successSavedVehicle
                } else {
                    state = .error
                }
            }
        }
        
        private func saveLocal() {
            state = .loading
            
            do {
                if let id = vehicle?.id {
                    try update(id: id)
                } else {
                    try insert()
                }
            } catch {
                state = .error
            }
        }
        
        private func update(id: String) throws {
            let descriptor = createUpdateDescriptor(for: id)
            
            let result = try modelContext.fetch(descriptor)
            
            if result.count == 1, let vehicleResult = result.first {
                vehicleResult.synced = false
                try modelContext.save()
                state = .successSavedVehicle
            } else {
                state = .error
            }
        }
        
        private func insert() throws {
            guard let vehicle else { return }
            
            modelContext.insert(vehicle)
            try modelContext.save()
                
            let descriptor = createInsertDescriptor(for: vehicle.name)

            let result = try modelContext.fetch(descriptor)
            
            if result.count == 1 {
                state = .successSavedVehicle
            } else {
                state = .error
            }
        }
        
        private func createUpdateDescriptor(for id: String) -> FetchDescriptor<Vehicle> {
            var descriptor = FetchDescriptor<Vehicle>(predicate: #Predicate { vehicle in
                vehicle.id == id
            })
            
            descriptor.fetchLimit = 1
            
            return descriptor
        }

        private func createInsertDescriptor(for name: String) -> FetchDescriptor<Vehicle> {
            var descriptor = FetchDescriptor<Vehicle>(predicate: #Predicate { vehicle in
                vehicle.name == name
            })
            
            descriptor.fetchLimit = 1
            
            return descriptor
        }
    }
}
