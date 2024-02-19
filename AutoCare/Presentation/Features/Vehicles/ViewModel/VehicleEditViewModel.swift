//
//  VehicleEditViewModel.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 30/10/23.
//

import Foundation
import RealmSwift
import Realm
import Combine
import FormValidator

extension VehicleEditView {
    @MainActor
    class ViewModel: ObservableObject {
        // MARK: - Published properties
        @Published var state: VehicleEditState = .idle
        @Published var vehicle: Vehicle
        @Published var vehicleTypes: [VehicleType]?
        @Published var isFormValid = false
        
        @Published var manager = FormManager(validationType: .immediate)
        
        // MARK: - Properties
        private var cancellable = Set<AnyCancellable>()
        private var realm: Realm
        
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
            vehicle: Vehicle = Vehicle(),
            realm: Realm
        ) {
            self.vehicle = vehicle
            self.realm = realm
            
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
        
        // MARK: - Func
        func fetchVehicleTypes() async {
            state = .loading

            let vehicleTypes = Array(realm.objects(VehicleType.self)).sorted(by: { $0.name < $1.name })

            state = .successVehicleTypes(vehicleTypes)
        }
        
        func save() async {
            state = .loading
            
            if manager.triggerValidation() {
                guard let odometer = Int(self.odometer) else { return }
                
                do {
                    vehicle.vehicleType = vehicleTypes?.first { $0.name == selectedVehicleType }
                    vehicle.name = self.name
                    vehicle.brand = self.brand
                    vehicle.model = self.model
                    vehicle.year = self.year
                    vehicle.licensePlate = self.licensePlate
                    vehicle.odometer = odometer
                    
                    guard let userId = AutoCareApp.app.currentUser?.id else {
                        throw RLMError(.fail)
                    }
                    
                    vehicle.owner_id = userId
                    
                    try await realm.asyncWrite {
                        realm.add(vehicle)
                    }
                    
                    state = .successSavedVehicle
                } catch {
                    print(error)
                    state = .error
                }
            }
        }
    }
}
