//
//  AutoCareApp.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 27/10/23.
//

import SwiftUI
import RealmSwift

@main
struct AutoCareApp: SwiftUI.App {
    private var app = App(id: Config.appId)
    
    var body: some Scene {
        WindowGroup {
            MileageListView(viewModel: MileageListView.ViewModel())
                .environmentObject(app)
        }
    }
}
