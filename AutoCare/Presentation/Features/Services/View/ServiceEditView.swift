//
//  ServiceEditView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 15/08/26.
//

import SwiftData
import SwiftUI
import TTProgressHUD

struct ServiceEditView: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var navigationPath: NavigationPath

    @State private var isLoading: Bool
    @State private var totalCostValue: Int
    @State private var odometer: Int

    var currencyFormatter: NumberFormatterProtocol
    var integerFormatter: NumberFormatterProtocol

    init(
        viewModel: ViewModel,
        navigationPath: Binding<NavigationPath>,
        currencyFormatter: NumberFormatterProtocol,
        integerFormatter: NumberFormatterProtocol
    ) {
        self.viewModel = viewModel
        self._navigationPath = navigationPath
        self.currencyFormatter = currencyFormatter
        self.integerFormatter = integerFormatter

        _totalCostValue = State(initialValue: 0)
        _odometer = State(initialValue: 0)
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
                isLoading = newState == .loading
            }
            .onChange(of: totalCostValue) { _, newValue in
                viewModel.totalCost = "\(Decimal(newValue) / 100.0)"
            }
            .onChange(of: odometer) { _, newValue in
                viewModel.odometer = "\(newValue / 100)"
            }
            .onChange(of: viewModel.type) { _, _ in
                viewModel.ensureValidSubtype()
            }
            .onReceive(viewModel.$state, perform: handleSaveState)
            .task(id: viewModel.taskId) {
                await loadForm()
            }
    }

    private var formStack: some View {
        Form {
            serviceSection
            commentSection
        }
        .environment(\.locale, Locale(identifier: "pt_BR"))
    }

    private var serviceSection: some View {
        Section("Serviço") {
            DatePicker(
                "Data",
                selection: $viewModel.date,
                in: ...Date.now,
                displayedComponents: [.date, .hourAndMinute]
            )
            .environment(\.font, Font.body)
            .validation(viewModel.dateValidation)
            .brandFormListRow()

            Picker("Tipo", selection: $viewModel.type) {
                ForEach(VehicleServiceType.allCases) { type in
                    Text(type.description).tag(type)
                }
            }
            .brandFormListRow()

            Picker("Subtipo", selection: $viewModel.subtype) {
                ForEach(viewModel.type.subtypes) { subtype in
                    Text(subtype.description).tag(subtype)
                }
            }
            .brandFormListRow()

            LabeledContent("Custo total") {
                CurrencyTextField(numberFormatter: currencyFormatter, value: $totalCostValue)
                    .validation(viewModel.totalCostValidation)
            }
            .brandFormListRow()

            LabeledContent("Odômetro") {
                CurrencyTextField(numberFormatter: integerFormatter, value: $odometer)
            }
            .brandFormListRow()
        }
    }

    private var commentSection: some View {
        Section("Observações") {
            TextField("Comentário", text: $viewModel.comment, axis: .vertical)
                .lineLimit(3...6)
                .brandFormListRow()
        }
    }

    private func handleSaveState(_ state: ServiceEditState) {
        if case .successSave = state {
            viewModel.goBackToServices(navigationPath: $navigationPath)
        }
    }

    private func loadForm() async {
        if viewModel.isEditing {
            isLoading = true
            await viewModel.reloadExistingService()
            applyFormSnapshot(viewModel.formSnapshotForExistingService())
            isLoading = false
        }
    }

    private func applyFormSnapshot(_ snapshot: ViewModel.FormSnapshot?) {
        guard let snapshot else { return }

        totalCostValue = snapshot.totalCostValue
        odometer = snapshot.odometerValue
    }

    private var navigationTitle: String {
        viewModel.isEditing ? "Editar Serviço" : "Novo Serviço"
    }
}

#Preview {
    ServiceEditView(
        viewModel: ServiceEditView.ViewModel(serviceClientId: nil, vehicleId: "1"),
        navigationPath: .constant(NavigationPath()),
        currencyFormatter: PreviewNumberFormatter(locale: Locale(identifier: "pt_BR")),
        integerFormatter: PreviewNumberFormatter(locale: Locale(identifier: "pt_BR"))
    )
    .modelContainer(SwiftDataManager.shared.previewModelContainer)
}
