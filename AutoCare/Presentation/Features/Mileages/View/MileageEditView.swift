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
    @State private var fuelCost = 0
    @State private var odometer = 0
    @State private var liters = 0
    
    private var currencyFormatter: NumberFormatterProtocol
    private var decimalFormatter: NumberFormatterProtocol
    private var integerFormatter: NumberFormatterProtocol
    
    init(
        viewModel: MileageEditView.ViewModel,
        navigationPath: Binding<NavigationPath>,
        currencyFormatter: NumberFormatterProtocol = NumberFormatter(),
        decimalFormatter: NumberFormatterProtocol = NumberFormatter(),
        integerFormatter: NumberFormatterProtocol = NumberFormatter()
    ) {
        self.viewModel = viewModel
        self.navigationPath = navigationPath
        
        self.currencyFormatter = currencyFormatter
        self.currencyFormatter.numberStyle = .currency
        self.currencyFormatter.maximumFractionDigits = 2
        
        self.decimalFormatter = decimalFormatter
        self.decimalFormatter.numberStyle = .decimal
        self.decimalFormatter.maximumFractionDigits = 3
        self.decimalFormatter.minimumFractionDigits = 3
        self.decimalFormatter.currencySymbol = ""
        
        self.integerFormatter = integerFormatter
        self.integerFormatter.numberStyle = .none
        self.integerFormatter.maximumFractionDigits = 0
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
                            .validation(viewModel.totalCostValidation)
                    }
                    
                    HStack {
                        Text("Custo Por Litro")
                        CurrencyTextField(numberFormatter: currencyFormatter, value: $fuelCost)
                    }
                    
                    HStack {
                        Text("Litros")
                        CurrencyTextField(numberFormatter: decimalFormatter, value: $liters)
                    }
                    
                    HStack {
                        Text("Odômetro")
                        CurrencyTextField(numberFormatter: integerFormatter, value: $odometer)
                    }
                    
                    Toggle("Completo", isOn: $viewModel.complete)
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
            })
            .onChange(of: fuelCost, { _, newState in
                viewModel.fuelCost = "\(Decimal(newState) / 100.0)"
            })
            .onChange(of: odometer, { _, newState in
                viewModel.odometer = "\(Decimal(newState) / 100.0)"
                viewModel.updateOdometerDifference()
            })
            .onChange(of: liters, { _, newState in
                viewModel.liters = (Decimal(newState) / 100.0)
            })
        }
        .task {
            await viewModel.fetchPreviousVehicleMileage()
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
