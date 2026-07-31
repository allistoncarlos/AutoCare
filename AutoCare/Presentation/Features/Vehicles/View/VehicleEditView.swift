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
    @Environment(\.colorScheme) private var colorScheme

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
        NavigationStack {
            ScrollView {
                VStack(spacing: BrandTheme.Spacing.lg) {
                    BrandSectionHeader(title: "Veículo", accent: BrandTheme.Colors.violetSoft)

                    BrandCard {
                        VStack(spacing: BrandTheme.Spacing.md) {
                            Picker("", selection: $form.selectedVehicleType) {
                                ForEach(viewModel.vehicleTypes, id: \.name) { vehicleType in
                                    Text(vehicleType.emoji)
                                        .tag(vehicleType.id)
                                }
                            }
                            .pickerStyle(.segmented)
                            .validation(form.selectedVehicleTypeValidation)

                            formField("Nome", text: $form.name, validation: form.nameValidation)
                            formField("Marca", text: $form.brand, validation: form.brandValidation)
                            formField("Modelo", text: $form.model, validation: form.modelValidation)

                            VStack(alignment: .leading, spacing: BrandTheme.Spacing.xs) {
                                Text("Ano")
                                    .font(BrandTheme.Typography.caption(12))
                                    .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
                                Picker("Ano", selection: $selectedYear) {
                                    ForEach(selectableYears, id: \.self) {
                                        Text($0)
                                    }
                                }
                                .pickerStyle(.menu)
                                .validation(form.yearValidation)
                            }

                            formField("Placa", text: $form.licensePlate, validation: form.licensePlateValidation)
                            formField("Odômetro", text: $form.odometer, validation: form.odometerValidation, keyboard: .numberPad)
                        }
                    }

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
                    .disabled(!form.isFormValid)
                    .buttonStyle(MainButtonStyle())

                    SignatureBadge()
                        .padding(.top, BrandTheme.Spacing.sm)
                }
                .padding(BrandTheme.Spacing.lg)
            }
            .brandBackground()
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        isPresented = false
                    }
                    .foregroundStyle(BrandTheme.Colors.violetCore)
                }
            }
        }
        .tint(BrandTheme.Colors.violetCore)
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

    private func formField(
        _ label: String,
        text: Binding<String>,
        validation: ValidationContainer,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: BrandTheme.Spacing.xs) {
            Text(label)
                .font(BrandTheme.Typography.caption(12))
                .foregroundStyle(BrandTheme.Colors.textMuted(colorScheme))
            TextField(label, text: text)
                .keyboardType(keyboard)
                .font(BrandTheme.Typography.body())
                .padding(BrandTheme.Spacing.md)
                .background(BrandTheme.Colors.backgroundElevated(colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: BrandTheme.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: BrandTheme.Radius.md)
                        .stroke(BrandTheme.Colors.border(colorScheme), lineWidth: 1)
                )
                .validation(validation)
        }
    }
}

#Preview {
    VehicleEditView(
        viewModel: VehicleEditView.ViewModel(vehicleId: nil),
        isPresented: .constant(true)
    )
    .modelContainer(SwiftDataManager.shared.previewModelContainer)
    .preferredColorScheme(.dark)
}
