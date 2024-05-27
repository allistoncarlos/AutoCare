//
//  MileageEditView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 11/04/24.
//

import SwiftUI
import RealmSwift
import TTProgressHUD

struct MileageEditView: View {
    @ObservedObject var viewModel: ViewModel
    var navigationPath: Binding<NavigationPath>
    
    @State private var isLoading = true
    
    @State private var isSubtitleHidden = false
    @State private var totalCostValue = 0
    
    private var numberFormatter: NumberFormatterProtocol
    
    init(
        viewModel: MileageEditView.ViewModel,
        navigationPath: Binding<NavigationPath>,
        numberFormatter: NumberFormatterProtocol = NumberFormatter()
    ) {
        self.viewModel = viewModel
        self.navigationPath = navigationPath
        
        self.numberFormatter = numberFormatter
        self.numberFormatter.numberStyle = .currency
        self.numberFormatter.maximumFractionDigits = 2
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Abastecimento")) {
                    DatePicker(selection: $viewModel.date, in: ...Date.now, displayedComponents: [.date, .hourAndMinute]) {
                        Text("Data")
                    }
                    .validation(viewModel.dateValidation)

//                    TextField("Custo total", value: $viewModel.totalCost, format: .number.precision(.fractionLength(2)))
//                        .keyboardType(.decimalPad)
                    
                    CurrencyTextField(numberFormatter: numberFormatter, value: $totalCostValue)
//                        .padding(20)
//                        .overlay(RoundedRectangle(cornerRadius: 16)
//                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2))
//                        .frame(height: 100)
                    
//                    CurrencyField(
//                        "Enter meal cost",
//                        value: Binding(get: {
//                            viewModel.totalCost.map { NSDecimalNumber(decimal: $0) }
//                        }, set: { number in
//                            viewModel.totalCost = number?.decimalValue
//                        })
//                    ).keyboardType(.decimalPad)
                    
                    
//                        .validation(viewModel.totalCostValidation)
                    
//                    TextField("Custo total", text: $viewModel.totalCost)
//                        .keyboardType(.decimalPad)
//                    TextField("Amount", value: $amount, format: .number.precision(.fractionLength(2)))
//                                .keyboardType(.decimalPad)
//                        .validation(viewModel.totalCostValidation)
                }
            }
//            .navigationTitle(viewModel.vehicleMileage ? "Novo abastecimento" : "\(viewModel.vehicleMileage?.liters)")
            .toolbar {
                Button("Salvar") {
                    Task {
                        await viewModel.save()
                    }
                }
            }
            .disabled(isLoading)
            .overlay(
                TTProgressHUD($isLoading, config: AutoCareApp.hudConfig)
            )
            .onChange(of: viewModel.state, { _, newState in
                isLoading = newState == .loading
            })
            .onChange(of: totalCostValue, { _, newState in
                viewModel.totalCost = Decimal(newState) / 100.0
            })
        }
        .task {
            await viewModel.fetchLastVehicleMileage()
        }
    }
}

#Preview {
    MileageEditView(
        viewModel: MileageEditView.ViewModel(
            realm: try! Realm(),
            vehicleMileage: VehicleMileage(),
            vehicleId: try! ObjectId(string: "65f7489acdac2f577161d7f7")
        ),
        navigationPath: .constant(
            NavigationPath()
        ),
        numberFormatter:
            PreviewNumberFormatter(locale: Locale(identifier: "pt_BR"))
    )
}
