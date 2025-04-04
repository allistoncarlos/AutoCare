//
//  VehicleEditView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import SwiftUI
import TTProgressHUD
import SwiftData

struct VehicleEditView: View {
    @ObservedObject var viewModel: ViewModel
    
    @State private var isLoading = true
    @State private var selectedYear = ""
    
    @StateObject var networkConnectivity = NetworkConnectivity()
    
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
                Picker("", selection: $viewModel.selectedVehicleType) {
                    ForEach(viewModel.vehicleTypes, id: \.name) { vehicleType in
                        Text(vehicleType.emoji)
                            .tag(vehicleType.id)
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
            
            Section(footer:
                Button("Salvar") {
                    Task {
                        await viewModel.save(isConnected: networkConnectivity.status == .connected)
                    }
                }
                .disabled(!viewModel.isFormValid)
                .buttonStyle(MainButtonStyle())
            ) {
                EmptyView()
            }
        }
        .navigationTitle(title)
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
            await viewModel.fetchData(isConnected: networkConnectivity.status == .connected)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    
    VehicleEditView(
        viewModel: VehicleEditView.ViewModel(
            modelContext: ModelContext(
                try! ModelContainer(for: Vehicle.self, configurations: config)
            ),
            vehicleId: nil
        ),
        isPresented: .constant(true)
    )
}
