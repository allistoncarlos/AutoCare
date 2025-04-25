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

extension VehicleEditView.ViewModel {
    actor ViewModelState {
        let statePublisher = CurrentValueSubject<VehicleEditState, Never>(.idle)
        let vehicleTypesPublisher = PassthroughSubject<[VehicleType], Never>()
        let selectedVehicleTypePublisher = PassthroughSubject<VehicleType, Never>()
        let vehiclePublisher = PassthroughSubject<Vehicle, Never>()
        
        var cancellable = Set<AnyCancellable>()
        var networkConnectivity = NetworkConnectivity()
        
        func setState(_ newState: VehicleEditState) {
            statePublisher.send(newState)
        }

        func setVehicleTypes(_ vehicleTypes: [VehicleType]) {
            vehicleTypesPublisher.send(vehicleTypes)
        }
        
        func setSelectedVehicleType(_ vehicleType: VehicleType) {
            selectedVehicleTypePublisher.send(vehicleType)
        }
        
        func setVehicle(_ vehicle: Vehicle) {
            vehiclePublisher.send(vehicle)
        }
        
        func store(_ cancellable: AnyCancellable) {
            self.cancellable.insert(cancellable)
        }
    }
}

extension VehicleEditView {
    final class ViewModel: ObservableObject, Sendable {
        let modelContainer: ModelContainer
        
        // TODO: REMOVER ESSA GALERA AQUI
        //@Published var vehicleId: String? = nil
//        @Published var isFormValid = false
        
        let stateStore = ViewModelState()
        
        var selectedVehicle: Vehicle?
        
        let isDefault: Bool = true // TODO: Permitir que o usuário marque um carro como favorito, retirando o favorito dos outros

        // MARK: - Validations
//        lazy var nameValidation = _name.validation(manager: manager)
//        lazy var selectedVehicleTypeValidation = _selectedVehicleType.validation(manager: manager)
//        lazy var brandValidation = _brand.validation(manager: manager)
//        lazy var modelValidation = _model.validation(manager: manager)
//        lazy var yearValidation = _year.validation(manager: manager)
//        lazy var licensePlateValidation = _licensePlate.validation(manager: manager)
//        lazy var odometerValidation = _odometer.validation(manager: manager)
        
        // MARK: - Init
        init(
            modelContainer: ModelContainer,
            vehicleId: String?
        ) {
            self.modelContainer = modelContainer
//            self.vehicleId = vehicleId

            Task {
                let cancellable = await stateStore.statePublisher
                    .sink { [weak self] state in
                        switch state {
                        case let .successVehicleTypes(vehicleTypes):
                            Task {
                                await self?.stateStore.setVehicleTypes(vehicleTypes)
                                
                                if let vehicleId {
                                    await self?.fetchVehicle(vehicleId: vehicleId)
                                }
                            }
                        case let .successVehicle(vehicle):
                            Task {
                                // TODO: CRIAR MÉTODO SETFORMDATA??? OU LEVAR PRO STATESTORE? TALVEZ NA VIEW...
                                
                                await self?.stateStore.setVehicle(vehicle)
                            }
                        default:
                            break
                        }
                    }

                await stateStore.store(cancellable)
            }
        }

        func fetchData() async {
            do {
                await stateStore.setState(.loading)
                
                let result: [VehicleType] = try await SwiftDataManager.shared.fetch()
                
                await stateStore.setState(.successVehicleTypes(result))
            } catch {
                print(error.localizedDescription)
                await stateStore.setState(.error)
            }
        }
        
        func fetchVehicle(vehicleId: String) async {
            do {
                await stateStore.setState(.loading)

                let result: Vehicle? = try await SwiftDataManager.shared.fetch(
                    where: #Predicate<Vehicle> { $0.id == vehicleId }
                )
                
                selectedVehicle = result
                
                if let result {
                    await stateStore.setState(.successVehicle(result))
                }
            } catch {
                print(error.localizedDescription)
                await stateStore.setState(.error)
            }
        }
        
//        private func triggerValidation() {
//            isFormValid = manager.triggerValidation()
//        }

        func save(
            odometer: String,
            name: String,
            brand: String,
            model: String,
            year: String,
            licensePlate: String,
            isDefault: Bool,
            vehicleTypeId: String
        ) async {
//        func save() async {
            do {
                await stateStore.setState(.loading)
                
                guard let odometer = Int(odometer) else { return }
                
                let vehicle = selectedVehicle == nil ?
                    Vehicle(
                        name: name,
                        brand: brand,
                        model: model,
                        year: year,
                        licensePlate: licensePlate,
                        odometer: odometer,
                        isDefault: isDefault,
                        vehicleTypeId: vehicleTypeId
                    ) : selectedVehicle // TODO: PRO UPDATE, ATUALIZAR OS VALORES EM SELECTEDVEHICLE??? OU USAR NEWVEHICLE???

                guard let vehicle else { return }
                vehicle.synced = false

                try await SwiftDataManager.shared.save(id: vehicle.id, item: vehicle)
                
                await stateStore.setState(.successSavedVehicle)
            } catch {
                print(error.localizedDescription)
                await stateStore.setState(.error)
            }
        }
    }
}
