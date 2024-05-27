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
    @State private var odometer = 0
    
    private var currencyFormatter: NumberFormatterProtocol
    private var decimalFormatter: NumberFormatterProtocol
    
    init(
        viewModel: MileageEditView.ViewModel,
        navigationPath: Binding<NavigationPath>,
        currencyFormatter: NumberFormatterProtocol = NumberFormatter(),
        decimalFormatter: NumberFormatterProtocol = NumberFormatter()
    ) {
        self.viewModel = viewModel
        self.navigationPath = navigationPath
        
        self.currencyFormatter = currencyFormatter
        self.currencyFormatter.numberStyle = .currency
        self.currencyFormatter.maximumFractionDigits = 2
        
        self.decimalFormatter = decimalFormatter
        self.decimalFormatter.numberStyle = .decimal
        self.decimalFormatter.maximumFractionDigits = 3
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Abastecimento")) {
                    DatePicker(selection: $viewModel.date, in: ...Date.now, displayedComponents: [.date, .hourAndMinute]) {
                        Text("Data")
                    }
                    .validation(viewModel.dateValidation)

                    HStack {
                        Text("Custo total")
                        CurrencyTextField(numberFormatter: currencyFormatter, value: $totalCostValue)
                    }
                    
                    HStack {
                        Text("Odômetro")
                        CurrencyTextField(numberFormatter: decimalFormatter, value: $odometer)
                    }
                }
            }
            .navigationTitle(viewModel.vehicleMileage == nil ? "Novo abastecimento" : "\(viewModel.vehicleMileage!.liters)")
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
                viewModel.totalCost = "\(Decimal(newState) / 100.0)"
            })
            .onChange(of: odometer, { _, newState in
                viewModel.odometer = "\(Decimal(newState) / 100.0)"
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
        currencyFormatter:
            PreviewNumberFormatter(locale: Locale(identifier: "pt_BR"))
    )
}
