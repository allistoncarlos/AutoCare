//
//  NavigationViewModifier.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 04/05/24.
//

import SwiftUI

struct NavigationViewModifier: ViewModifier {
    let title: String?
    let color: Color?
    var displayMode: NavigationBarItem.TitleDisplayMode = .inline

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .brandNavigation(title: title, displayMode: displayMode)
            .toolbarBackground(color ?? BrandTheme.Colors.backgroundSurface(colorScheme), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(colorScheme == .dark ? .dark : .light, for: .tabBar)
    }
}
