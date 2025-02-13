//
//  HomeView.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 09/11/24.
//

import SwiftUI
import Realm

struct HomeView: View {
    @EnvironmentObject var app: RLMApp
    @ObservedObject var mileageListViewViewModel: MileageListView.ViewModel
    
    var body: some View {
        TabView {
            HomeRouter.makeMileageListView()
                .environmentObject(app)
                .tabItem {
                    Label("Dashboard", systemImage: "display")
                }
            
            HomeRouter.makeServiceListView()
                .environmentObject(app)
                .tabItem {
                    Label("Serviços", systemImage: "car.badge.gearshape")
                }
        }
    }
}

#Preview {
    HomeView(mileageListViewViewModel: MileageListView.ViewModel())
}
