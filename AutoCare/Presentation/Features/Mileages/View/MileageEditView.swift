//
//  MileageEditView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 11/04/24.
//

import SwiftUI
import RealmSwift

struct MileageEditView: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Abastecimento")) {
                    
                }
            }
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
        )
    )
}
