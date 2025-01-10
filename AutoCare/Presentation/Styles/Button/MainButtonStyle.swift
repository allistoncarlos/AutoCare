//
//  MainButtonStyle.swift
//  AutoCare
//
//  Created by Alliston Aleixo on 21/02/24.
//

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(
                minWidth: 0,
                maxWidth: .infinity
            )
            .background(isEnabled ? .blue : .gray)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .font(.system(size: 18, weight: .bold))
    }
}
