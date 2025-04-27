//
//  VehicleEditView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import SwiftUI
import TTProgressHUD
import SwiftData
import FormValidator

class VehicleEditForm: ObservableObject {
    @Published var manager = FormManager(validationType: .immediate)
    @Published var isFormValid: Bool = false

    @FormField(validator: NonEmptyValidator(message: "Campo Nome obrigatório"))
    var name: String = "" { didSet { self.triggerValidation()} }
    
    @FormField(validator: NonEmptyValidator(message: "Selecione o Tipo do Veículo"))
    var selectedVehicleType: String = "" { didSet { self.triggerValidation()} }
    
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

    lazy var nameValidation = _name.validation(manager: manager)
    lazy var selectedVehicleTypeValidation = _selectedVehicleType.validation(manager: manager)
    lazy var brandValidation = _brand.validation(manager: manager)
    lazy var modelValidation = _model.validation(manager: manager)
    lazy var yearValidation = _year.validation(manager: manager)
    lazy var licensePlateValidation = _licensePlate.validation(manager: manager)
    lazy var odometerValidation = _odometer.validation(manager: manager)
    
    private func triggerValidation() {
        isFormValid = manager.triggerValidation()
    }
}

struct VehicleEditView: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var form = VehicleEditForm()
    
    @State private var isLoading = true
    @State private var selectedYear = ""
    @State private var stateStore = VehicleEditView.ViewModel.ViewModelState()
    @State private var state: VehicleEditState = .idle
    @State private var vehicleTypes: [VehicleType] = []
    @State private var selectedVehicleType: String = ""
    
    @Binding var isPresented: Bool
    
    var currentYear: Int = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year!
    
    var selectableYears: [String] {
        var years: [String] = []
        
        for year in 1960...currentYear {
            years.append(String(year))
        }
        
        years.append("")
        
        return years.reversed()
    }
    
    var title: String {
        // TODO: ORGANIZAR AO FAZER O UPDATE
        return ""
    }

    var body: some View {
        Form {
            Section(header: Text("Veículo")) {
                Picker("", selection: $form.selectedVehicleType) {
                    ForEach(vehicleTypes, id: \.name) { vehicleType in
                        Text(vehicleType.emoji)
                            .tag(vehicleType.id)
                    }
                }
                .pickerStyle(.segmented)
                .validation(form.selectedVehicleTypeValidation)
                
                TextField("Nome", text: $form.name)
                    .validation(form.nameValidation)
                
                TextField("Marca", text: $form.brand)
                    .validation(form.brandValidation)
                
                TextField("Modelo", text: $form.model)
                    .validation(form.modelValidation)
                
                Picker("Ano", selection: $selectedYear) {
                    ForEach(selectableYears, id: \.self) {
                        Text($0)
                    }
                }
                .validation(form.yearValidation)
                
                TextField("Placa", text: $form.licensePlate)
                    .validation(form.licensePlateValidation)
                
                TextField("Odômetro", text: $form.odometer)
                    .keyboardType(.numberPad)
                    .validation(form.odometerValidation)
            }
            
            Section(
                footer:
                    Button("Salvar") {
                        Task {
                            if form.isFormValid {
                                await viewModel.save(
                                    odometer: form.odometer,
                                    name: form.name,
                                    brand: form.brand,
                                    model: form.model,
                                    year: selectedYear,
                                    licensePlate: form.licensePlate,
                                    isDefault: true,
                                    vehicleTypeId: form.selectedVehicleType
                                )
                        }
                    }
                }
                .disabled(!form.isFormValid)
                .buttonStyle(MainButtonStyle())
            ) {
                EmptyView()
            }
        }
        .navigationTitle(title)
        .disabled(isLoading)
        .overlay(
            TTProgressHUD($isLoading, config: AutoCareApp.hudConfig)
        )
        .onChange(of: state, { _, newState in
            isLoading = newState == .loading
            
            if newState == .successSavedVehicle {
                isPresented = false
            }
        })
        .onChange(of: selectedYear, { _, newYear in
            form.year = newYear
        })
        .task {
            await syncData()
        }
    }
    
    func syncData() async {
        await stateStore.store(await viewModel.stateStore.statePublisher.sink { self.state = $0})
        await stateStore.store(await viewModel.stateStore.vehicleTypesPublisher.sink { self.vehicleTypes = $0 })
        await stateStore.store(await viewModel.stateStore.selectedVehicleTypePublisher.sink { self.selectedVehicleType = $0.id })
        
        await viewModel.fetchData()
    }
}

#Preview {
    VehicleEditView(
        viewModel: VehicleEditView.ViewModel(
            modelContainer: SwiftDataManager.shared.previewModelContainer,
            vehicleId: nil
        ),
        isPresented: .constant(true)
    )
}
