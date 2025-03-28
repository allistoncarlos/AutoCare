//
//  MileageEditView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 11/04/24.
//

import SwiftUI
import TTProgressHUD

struct MileageEditView: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var navigationPath: NavigationPath
    
    @State private var isLoading = true
    
    @State private var isSubtitleHidden = false
    @State private var totalCostValue = 0
    @State private var fuelCost = 0
    @State private var odometer = 0
    @State private var liters = 0
    @State private var isComplete = true
    
    var currencyFormatter: NumberFormatterProtocol
    var decimalFormatter: NumberFormatterProtocol
    var integerFormatter: NumberFormatterProtocol
    
    var body: some View {
        Form {
            Section(header: Text("Abastecimento")) {
                DatePicker(selection: $viewModel.date, in: ...Date.now, displayedComponents: [.date, .hourAndMinute]) {
                    Text("Data")
                }
                .validation(viewModel.dateValidation)

                HStack {
                    Text("Custo total")
                    CurrencyTextField(numberFormatter: currencyFormatter, value: $totalCostValue)
                        .validation(viewModel.totalCostValidation)
                }
                
                HStack {
                    Text("Custo Por Litro")
                    CurrencyTextField(numberFormatter: currencyFormatter, value: $fuelCost)
                }
                
                HStack {
                    Text("Litros")
                    CurrencyTextField(numberFormatter: decimalFormatter, value: $liters)
                        .disabled(isComplete)
                }
                
                HStack {
                    Text("Odômetro")
                    CurrencyTextField(numberFormatter: integerFormatter, value: $odometer)
                }
                
                Toggle("Completo", isOn: $isComplete)
            }
            
            if let odometerDifference = viewModel.odometerDifference, odometerDifference > 0 {
                Section(header: Text("Diferença de abastecimento")) {
                    VStack(alignment: .leading) {
                        Text("\(odometerDifference) km").font(.subheadline)
                    }
                    .padding([.leading, .trailing], 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .listRowInsets(EdgeInsets())
                    .background(Color(UIColor.systemGroupedBackground))
                }
            }
            
            if let previousMileage = viewModel.previousMileage {
                Section(header: Text("Abastecimento anterior")) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Data").font(.headline)
                            Spacer()
                            Text(previousMileage.date.toFormattedString(dateFormat: AutoCareApp.dateTimeFormat)).font(.headline)
                        }
                        
                        HStack {
                            Text("Odômetro").font(.subheadline)
                            Spacer()
                            Text("\(previousMileage.odometer) km").font(.subheadline)
                        }
                        
                        HStack {
                            Text("Diferença").font(.subheadline)
                            Spacer()
                            Text("\(previousMileage.odometerDifference) km").font(.subheadline)
                        }
                        
                        HStack {
                            if let totalCost = previousMileage.totalCost.toCurrencyString() {
                                Text("Custo Total").font(.subheadline)
                                Spacer()
                                Text(totalCost).font(.subheadline)
                            }
                        }
                            
                        HStack {
                            if let fuelCost = previousMileage.fuelCost.toCurrencyString() {
                                Text("Preço Litro").font(.subheadline)
                                Spacer()
                                Text(fuelCost).font(.subheadline)
                            }
                        }
                        
                        HStack {
                            Text("Litros").font(.subheadline)
                            Spacer()
                            Text("\(previousMileage.liters) L").font(.subheadline)
                        }
                        
                        HStack {
                            Text("Consumo").font(.subheadline)
                            Spacer()
                            Text("\(previousMileage.calculatedMileage) km/L").font(.subheadline)
                        }
                    }
                    .padding([.leading, .trailing], 20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .listRowInsets(EdgeInsets())
                    .background(Color(UIColor.systemGroupedBackground))
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
            
            calculateLiters()
        })
        .onChange(of: fuelCost, { _, newState in
            viewModel.fuelCost = "\(Decimal(newState) / 100.0)"
            
            calculateLiters()
        })
        .onChange(of: odometer, { _, newState in
            viewModel.odometer = "\(Decimal(newState) / 100.0)"
            viewModel.updateOdometerDifference()
        })
        .onChange(of: liters, { _, newState in
            viewModel.liters = (Decimal(newState) / 100.0)
        })
        .onChange(of: isComplete, { _, newState in
            viewModel.complete = newState
        })
        .onReceive(viewModel.$state) { state in
            if case .successSave = state {
                viewModel.goBackToMileages(navigationPath: $navigationPath)
            }
        }
        .task {
            await viewModel.fetchPreviousVehicleMileage()
        }
    }
    
    private func calculateLiters() {
        if isComplete {
            guard fuelCost > 0 else {
                return
            }
            
            let result = (Decimal(totalCostValue) / Decimal(fuelCost)) * 100
            liters = Int(NSDecimalNumber(decimal: result).int16Value)
        }
    }

}

#Preview {
    MileageEditView(
        viewModel: MileageEditView.ViewModel(
            vehicleMileage: VehicleMileage(
                id: "123",
                date: Date(),
                totalCost: 131.55,
                odometer: 685,
                odometerDifference: 250,
                liters: 22.720,
                fuelCost: 5.97,
                calculatedMileage: 11.0,
                complete: true,
                vehicleId: "65f7489acdac2f577161d7f7"
            ),
            vehicleId: "1"
        ),
        navigationPath: .constant(
            NavigationPath()
        ),
        currencyFormatter:
            PreviewNumberFormatter(locale: Locale(identifier: "pt_BR")),
        decimalFormatter:
            PreviewNumberFormatter(locale: Locale(identifier: "pt_BR")),
        integerFormatter:
            PreviewNumberFormatter(locale: Locale(identifier: "pt_BR"))
    )
}
