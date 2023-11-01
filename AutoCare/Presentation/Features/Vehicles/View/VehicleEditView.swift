//
//  VehicleEditView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import SwiftUI
import RealmSwift

struct VehicleEditView: View {
    @ObservedObject var viewModel: ViewModel
    
    @State private var isLoading = true
    @State private var selectedVehicleType = ""
    @State private var odometerString = ""
    @State private var yearInt = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year!
    
    var currentYear: Int = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year!
    
    var body: some View {
        NavigationStack {
            Form {
                if let vehicleTypes = viewModel.vehicleTypes {
                    Section(header: Text("Veículo")) {
                        Picker("Vehicle Types", selection: $viewModel.selectedVehicleType) {
                            ForEach(vehicleTypes, id: \.name) { vehicleType in
                                Text(vehicleType.localizedName())
                                    .tag(vehicleType.name)
                            }
                        }.pickerStyle(.segmented)
                        
                        TextField("Nome", text: $viewModel.vehicle.name)
                        
                        TextField("Marca", text: $viewModel.vehicle.brand)
                        
                        TextField("Modelo", text: $viewModel.vehicle.model)
                        
                        Picker("Ano", selection: $yearInt) {
                            ForEach(
                                (
                                    1960...currentYear
                                ).reversed(),
                                id: \.self
                            ) {
                                Text(String($0))
                            }
                        }
                        
                        TextField("Placa", text: $viewModel.vehicle.licensePlate)
                        
                        TextField("Odômetro", text: $odometerString)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle(viewModel.vehicle.name.isEmpty ? "Novo Veículo" : viewModel.vehicle.name)
        }
        .disabled(isLoading)
        .overlay(
            Group {
                if isLoading {
                    ProgressView("Carregando")
                        .controlSize(.large)
                }
            }
        )
        .onChange(of: viewModel.state, { oldState, newState in
            isLoading = newState == .loading
        })
        .onChange(of: odometerString, { oldValue, newValue in
            if let odometer = Int(newValue) {
                viewModel.vehicle.odometer = odometer
            }
        })
        .onChange(of: yearInt, { oldValue, newValue in
            viewModel.vehicle.year = String(newValue)
        })
        .task {
            await viewModel.fetchVehicleTypes()
        }
    }
}

#Preview {
    VehicleEditView(viewModel: VehicleEditView.ViewModel(configuration: Realm.Configuration()))
}
