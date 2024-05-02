//
//  MileageEditView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 11/04/24.
//

import SwiftUI

struct MileageEditView: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack {
            Text("Hello, World!")
        }
    }
}

#Preview {
    MileageEditView(
        viewModel: MileageEditView.ViewModel(vehicleMileage: VehicleMileage()),
        navigationPath: .constant(
            NavigationPath()
        )
    )
}
