//
//  NotLoggedView.swift
//  AutoCare Watch App
//

import SwiftUI

struct NotLoggedView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "iphone")
                .font(.title2)
                .foregroundStyle(Color(red: 0.486, green: 0.227, blue: 0.929))

            Text("Login necessário")
                .font(.headline)

            Text("Abra o AutoCare no iPhone e faça login.")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    NotLoggedView()
}
