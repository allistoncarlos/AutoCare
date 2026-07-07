//
//  VehicleEditView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import FormValidator
import SwiftData
import SwiftUI
import TTProgressHUD

class VehicleEditForm: ObservableObject {
    @Published var manager = FormManager(validationType: .immediate)
    @Published var isFormValid: Bool = false

    @FormField(validator: NonEmptyValidator(message: "Campo Nome obrigatório"))
    var name: String = "" { didSet { triggerValidation() } }

    @FormField(validator: NonEmptyValidator(message: "Selecione o Tipo do Veículo"))
    var selectedVehicleType: String = "" { didSet { triggerValidation() } }

    @FormField(validator: NonEmptyValidator(message: "Campo Marca obrigatório"))
    var brand: String = "" { didSet { triggerValidation() } }

    @FormField(validator: NonEmptyValidator(message: "Campo Modelo obrigatório"))
    var model: String = "" { didSet { triggerValidation() } }

    @FormField(validator: NonEmptyValidator(message: "Campo Ano obrigatório"))
    var year: String = "" { didSet { triggerValidation() } }

    @FormField(validator: NonEmptyValidator(message: "Campo Placa obrigatório"))
    var licensePlate: String = "" { didSet { triggerValidation() } }

    @FormField(validator: NonEmptyValidator(message: "Campo Odômetro obrigatório"))
    var odometer: String = "" { didSet { triggerValidation() } }

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

    @State private var selectedYear = ""
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
        viewModel.vehicle == nil ? "Novo Veículo" : "Editar Veículo"
    }

    var body: some View {
        Form {
            Section(header: Text("Veículo")) {
                Picker("", selection: $form.selectedVehicleType) {
                    ForEach(viewModel.vehicleTypes, id: \.name) { vehicleType in
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
                                    vehicleTypeId: form.selectedVehicleType,
                                    isPresented: $isPresented
                                )
                            }
                        }
                    }
            ) {
                EmptyView()
            }
            .disabled(!form.isFormValid)
            .buttonStyle(MainButtonStyle())
        }
        .navigationTitle(title)
        .disabled(viewModel.state == .loading)
        .overlay(
            TTProgressHUD(
                .constant(viewModel.state == .loading),
                config: AutoCareApp.hudConfig
            )
        )
        .onChange(of: viewModel.vehicle) { _, vehicle in
            guard let vehicle else { return }
            form.selectedVehicleType = vehicle.vehicleTypeId
            form.name = vehicle.name
            form.brand = vehicle.brand
            form.model = vehicle.model
            selectedYear = vehicle.year
            form.licensePlate = vehicle.licensePlate
            form.odometer = String(vehicle.odometer)
        }
        .onChange(of: selectedYear) { _, newYear in
            form.year = newYear
        }
        .task {
            await viewModel.fetchData()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Vehicle.self, VehicleType.self, configurations: config)

    return VehicleEditView(
        viewModel: VehicleEditView.ViewModel(
            modelContext: container.mainContext,
            vehicleId: nil
        ),
        isPresented: .constant(true)
    )
}
