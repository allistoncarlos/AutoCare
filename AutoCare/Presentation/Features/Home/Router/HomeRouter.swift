//
//  HomeRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 09/11/24.
//

import SwiftUI
import RealmSwift

@MainActor
enum HomeRouter {
    static func makeMileageListView(realm: Realm, selectedVehicle: Vehicle) -> some View {
        return MileageListView(
            viewModel: MileageListView.ViewModel(realm: realm, selectedVehicle: selectedVehicle)
        )
    }
    
    static func makeServiceListView(realm: Realm, selectedVehicle: Vehicle) -> some View {
        return ServiceListView(
            viewModel: ServiceListView.ViewModel(realm: realm, selectedVehicle: selectedVehicle)
        )
    }
}
