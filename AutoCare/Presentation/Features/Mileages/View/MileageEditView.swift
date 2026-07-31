//
//  MileageEditView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 11/04/24.
//

import SwiftUI
import TTProgressHUD
import SwiftData

struct MileageEditView: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var navigationPath: NavigationPath

    @State private var isLoading: Bool
    @State private var totalCostValue: Int
    @State private var fuelCost: Int
    @State private var odometer: Int
    @State private var liters: Int
    @State private var isComplete: Bool

    var currencyFormatter: NumberFormatterProtocol
    var decimalFormatter: NumberFormatterProtocol
    var integerFormatter: NumberFormatterProtocol

    init(
        viewModel: ViewModel,
        navigationPath: Binding<NavigationPath>,
        currencyFormatter: NumberFormatterProtocol,
        decimalFormatter: NumberFormatterProtocol,
        integerFormatter: NumberFormatterProtocol
    ) {
        self.viewModel = viewModel
        self._navigationPath = navigationPath
        self.currencyFormatter = currencyFormatter
        self.decimalFormatter = decimalFormatter
        self.integerFormatter = integerFormatter

        _totalCostValue = State(initialValue: 0)
        _fuelCost = State(initialValue: 0)
        _odometer = State(initialValue: 0)
        _liters = State(initialValue: 0)
        _isComplete = State(initialValue: true)
        _isLoading = State(initialValue: viewModel.isEditing)
    }

    var body: some View {
        formStack
            .brandScreen()
            .brandNavigation(title: navigationTitle)
            .toolbar {
                Button("Salvar") {
                    Task { await viewModel.save() }
                }
                .foregroundStyle(BrandTheme.Colors.violetCore)
            }
            .tint(BrandTheme.Colors.violetCore)
            .disabled(isLoading)
            .overlay(TTProgressHUD($isLoading, config: AutoCareApp.hudConfig))
            .onChange(of: viewModel.state) { _, newState in
                handleStateChange(newState)
            }
            .onChange(of: totalCostValue) { _, newValue in
                handleTotalCostChange(newValue)
            }
            .onChange(of: fuelCost) { _, newValue in
                handleFuelCostChange(newValue)
            }
            .onChange(of: odometer) { _, newValue in
                handleOdometerChange(newValue)
            }
            .onChange(of: liters) { _, newValue in
                handleLitersChange(newValue)
            }
            .onChange(of: isComplete) { _, newValue in
                handleCompleteChange(newValue)
            }
            .onReceive(viewModel.$state, perform: handleSaveState)
            .task(id: viewModel.taskId) {
                await loadForm()
            }
    }

    private var formStack: some View {
        Form {
            fuelSection
            odometerDifferenceSection
            previousMileageSection
        }
        .environment(\.locale, Locale(identifier: "pt_BR"))
    }

    private func handleStateChange(_ newState: MileageEditState) {
        isLoading = newState == .loading
    }

    private func handleTotalCostChange(_ newState: Int) {
        viewModel.totalCost = "\(Decimal(newState) / 100.0)"
        calculateLiters()
    }

    private func handleFuelCostChange(_ newState: Int) {
        viewModel.fuelCost = "\(Decimal(newState) / 100.0)"
        calculateLiters()
    }

    private func handleOdometerChange(_ newState: Int) {
        viewModel.odometer = "\(Decimal(newState) / 100.0)"
        viewModel.updateOdometerDifference()
    }

    private func handleLitersChange(_ newState: Int) {
        viewModel.liters = (Decimal(newState) / 100.0)
    }

    private func handleCompleteChange(_ newState: Bool) {
        viewModel.complete = newState
    }

    private func handleSaveState(_ state: MileageEditState) {
        if case .successSave = state {
            viewModel.goBackToMileages(navigationPath: $navigationPath)
        }
    }

    private var fuelSection: some View {
        Section("Abastecimento") {
            DatePicker(
                "Data",
                selection: $viewModel.date,
                in: ...Date.now,
                displayedComponents: [.date, .hourAndMinute]
            )
            .environment(\.font, Font.body)
            .brandFormListRow()

            LabeledContent("Custo total") {
                CurrencyTextField(numberFormatter: currencyFormatter, value: $totalCostValue)
                    .validation(viewModel.totalCostValidation)
            }
            .brandFormListRow()

            LabeledContent("Custo por litro") {
                CurrencyTextField(numberFormatter: currencyFormatter, value: $fuelCost)
            }
            .brandFormListRow()

            LabeledContent("Litros") {
                CurrencyTextField(numberFormatter: decimalFormatter, value: $liters)
                    .disabled(isComplete)
            }
            .brandFormListRow()

            LabeledContent("Odômetro") {
                CurrencyTextField(numberFormatter: integerFormatter, value: $odometer)
            }
            .brandFormListRow()

            Toggle("Completo", isOn: $isComplete)
                .brandFormListRow()
        }
    }

    @ViewBuilder
    private var odometerDifferenceSection: some View {
        if let odometerDifference = viewModel.odometerDifference, odometerDifference > 0 {
            Section("Diferença de abastecimento") {
                LabeledContent(
                    "Percorridos desde o último abastecimento",
                    value: "\(odometerDifference) km"
                )
                .brandFormListRow()
            }
        }
    }

    @ViewBuilder
    private var previousMileageSection: some View {
        if let previousMileage = viewModel.previousMileage {
            Section("Abastecimento anterior") {
                previousMileageRows(previousMileage)
            }
        }
    }

    @ViewBuilder
    private func previousMileageRows(_ previousMileage: VehicleMileage) -> some View {
        LabeledContent(
            "Data",
            value: previousMileage.date.toFormattedString(dateFormat: AutoCareApp.dateTimeFormat)
        )
        .brandFormListRow()

        LabeledContent("Odômetro", value: "\(previousMileage.odometer) km")
            .brandFormListRow()

        LabeledContent("Diferença", value: "\(previousMileage.odometerDifference) km")
            .brandFormListRow()

        if let totalCost = previousMileage.totalCost.toCurrencyString() {
            LabeledContent("Custo total", value: totalCost)
                .brandFormListRow()
        }

        if let fuelCost = previousMileage.fuelCost.toCurrencyString() {
            LabeledContent("Preço por litro", value: fuelCost)
                .brandFormListRow()
        }

        if let liters = previousMileage.liters.toLeadingZerosString(decimalPlaces: 3) {
            LabeledContent("Litros", value: "\(liters) L")
                .brandFormListRow()
        }

        if let calculatedMileage = previousMileage.calculatedMileage.toLeadingZerosString(decimalPlaces: 3) {
            LabeledContent("Consumo", value: "\(calculatedMileage) km/L")
                .brandFormListRow()
        }
    }

    private func loadForm() async {
        if viewModel.isEditing {
            isLoading = true
            await viewModel.reloadExistingMileage()
            applyFormSnapshot(viewModel.formSnapshotForExistingMileage())
            isLoading = false
        }

        await viewModel.fetchPreviousVehicleMileage()
    }

    private func applyFormSnapshot(_ snapshot: ViewModel.FormSnapshot?) {
        guard let snapshot else { return }

        totalCostValue = snapshot.totalCostValue
        fuelCost = snapshot.fuelCostValue
        odometer = snapshot.odometerValue
        liters = snapshot.litersValue
        isComplete = snapshot.isComplete
    }

    private var navigationTitle: String {
        if let vehicleMileage = viewModel.vehicleMileage,
           let liters = vehicleMileage.liters.toLeadingZerosString(decimalPlaces: 3) {
            return liters
        }
        return "Novo abastecimento"
    }

    private func calculateLiters() {
        if isComplete, fuelCost > 0 {
            let result = (Decimal(totalCostValue) / Decimal(fuelCost)) * 100
            liters = Int(NSDecimalNumber(decimal: result).int16Value)
        }
    }
}

#Preview {
    MileageEditView(
        viewModel: MileageEditView.ViewModel(mileageClientId: "123", vehicleId: "1"),
        navigationPath: .constant(NavigationPath()),
        currencyFormatter: PreviewNumberFormatter(locale: Locale(identifier: "pt_BR")),
        decimalFormatter: PreviewNumberFormatter(locale: Locale(identifier: "pt_BR")),
        integerFormatter: PreviewNumberFormatter(locale: Locale(identifier: "pt_BR"))
    )
    .modelContainer(SwiftDataManager.shared.previewModelContainer)
}
