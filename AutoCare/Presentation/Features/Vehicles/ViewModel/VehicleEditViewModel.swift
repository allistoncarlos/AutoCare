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
        @Published var vehicle: VehicleData?
        @Published var vehicleId: String? = nil
        @Published var vehicleTypes = [VehicleTypeData]()
        @Published var isFormValid = false
        
        @Published var manager = FormManager(validationType: .immediate)
        
        @Injected(\.vehicleRepository) private var repository: VehicleRepositoryProtocol
        @Injected(\.vehicleTypeRepository) private var vehicleTypeRepository: VehicleTypeRepositoryProtocol
        
        // MARK: - Properties
        private var cancellable = Set<AnyCancellable>()
        
        // MARK: - Form Fields
        @FormField(validator: NonEmptyValidator(message: "Selecione o Tipo do Veículo"))
        var selectedVehicleType: String = ""
        
        @FormField(validator: NonEmptyValidator(message: "Campo Nome obrigatório"))
        var name: String = ""
        
        @FormField(validator: NonEmptyValidator(message: "Campo Marca obrigatório"))
        var brand: String = ""
        
        @FormField(validator: NonEmptyValidator(message: "Campo Modelo obrigatório"))
        var model: String = ""
        
        @FormField(validator: NonEmptyValidator(message: "Campo Ano obrigatório"))
        var year: String = ""
        
        @FormField(validator: NonEmptyValidator(message: "Campo Placa obrigatório"))
        var licensePlate: String = ""
        
        @FormField(validator: NonEmptyValidator(message: "Campo Odômetro obrigatório"))
        var odometer: String = ""

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
                
                let descriptor = FetchDescriptor<VehicleTypeData>(
                    sortBy: [SortDescriptor(\.name)]
                )

                let result = try modelContext.fetch(descriptor)
                
                state = .successVehicleTypes(result)
            } catch {
                state = .error
            }
        }
        
        private func syncData(_ vehicleTypes: [VehicleTypeData]) {
            do {
                try modelContext.delete(model: VehicleTypeData.self)
                
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

        func save() async {
//            state = .loading
//            
//            if manager.triggerValidation() {
//                guard let odometer = Int(self.odometer) else { return }
//                
//                do {
//                    guard let vehicle else { return }
//                    
////                    vehicle.vehicleType = vehicleTypes.first { $0.name == selectedVehicleType }
//                    vehicle.name = self.name
//                    vehicle.brand = self.brand
//                    vehicle.model = self.model
//                    vehicle.year = self.year
//                    vehicle.licensePlate = self.licensePlate
//                    vehicle.odometer = odometer
//                    
////                    try await realm.asyncWrite {
////                        realm.add(vehicle)
////                    }
//                    
//                    state = .successSavedVehicle
//                } catch {
//                    print(error)
//                    state = .error
//                }
//            }
        }
    }
}
