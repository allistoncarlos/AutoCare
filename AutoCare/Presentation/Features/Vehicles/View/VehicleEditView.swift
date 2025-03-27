//
//  VehicleEditView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import SwiftUI
import RealmSwift
import TTProgressHUD

struct VehicleEditView: View {
    @ObservedObject var viewModel: ViewModel
    
    @State private var isLoading = true
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
        if let name = viewModel.vehicle?.name {
            return name
        }
        
        return ""
    }
    
    var body: some View {
        Form {
            Section(header: Text("Veículo")) {
                Picker("Vehicle Types", selection: $viewModel.selectedVehicleType) {
                    ForEach(viewModel.vehicleTypes, id: \.name) { vehicleType in
                        Text(vehicleType.emoji)
                            .tag(vehicleType.name)
                    }
                }
                .pickerStyle(.segmented)
                .validation(viewModel.selectedVehicleTypeValidation)
                
                TextField("Nome", text: $viewModel.name)
                    .validation(viewModel.nameValidation)
                
                TextField("Marca", text: $viewModel.brand)
                    .validation(viewModel.brandValidation)
                
                TextField("Modelo", text: $viewModel.model)
                    .validation(viewModel.modelValidation)
                
                Picker("Ano", selection: $selectedYear) {
                    ForEach(selectableYears, id: \.self) {
                        Text($0)
                    }
                }
                .validation(viewModel.yearValidation)
                
                TextField("Placa", text: $viewModel.licensePlate)
                    .validation(viewModel.licensePlateValidation)
                
                TextField("Odômetro", text: $viewModel.odometer)
                    .keyboardType(.numberPad)
                    .validation(viewModel.odometerValidation)
            }
        }
        .navigationTitle(title)
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
            
            if newState == .successSavedVehicle {
                isPresented = false
            }
        })
        .onChange(of: selectedYear, { _, newYear in
            viewModel.year = newYear
        })
        .task {
            await viewModel.fetchVehicleTypes()
        }
    }
}

// TODO: VER COMO MOCKAR USER
//#Preview {
//    VehicleEditView(viewModel: VehicleEditView.ViewModel(configuration: Realm.Configuration()))
//}
