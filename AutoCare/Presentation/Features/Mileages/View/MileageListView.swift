//
//  MileageListView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 28/10/23.
//

import SwiftUI
import Realm

struct MileageListView: View {
    @EnvironmentObject var app: RLMApp
    
    @ObservedObject var viewModel: ViewModel
    @State private var isLoading = true
    @State private var isNewVehiclePresented = false
    
    var body: some View {
        Group {
            Text("Hello, World!")
        }
        .task {
            await viewModel.setup(app: app)
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
            
            isNewVehiclePresented = newState == .newVehicle
        })
        .sheet(isPresented: $isNewVehiclePresented) {
            if let user = app.currentUser, 
                let realm = viewModel.realm {
                VehicleEditView(
                    viewModel: VehicleEditView.ViewModel(realm: realm)
                )
                .interactiveDismissDisabled()
            }
        }
    }
}

#Preview {
    MileageListView(viewModel: MileageListView.ViewModel())
}
