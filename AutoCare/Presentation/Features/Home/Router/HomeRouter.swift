//
//  HomeRouter.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 09/11/24.
//

import SwiftUI

@MainActor
enum HomeRouter {
    static func makeMileageListView() -> some View {
        return MileageListView(viewModel: MileageListView.ViewModel())
    }
    
    static func makeServiceListView() -> some View {
        return ServiceListView(viewModel: ServiceListView.ViewModel())
    }
}
