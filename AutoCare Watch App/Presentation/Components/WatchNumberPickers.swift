//
//  WatchNumberPickers.swift
//  AutoCare Watch App
//

import SwiftUI

struct WatchMoneyPickerView: View {
    @Binding var cents: Int
    let title: String
    let maxReais: Int

    @State private var reais: Int
    @State private var centavos: Int

    init(cents: Binding<Int>, title: String, maxReais: Int) {
        self._cents = cents
        self.title = title
        self.maxReais = maxReais
        self._reais = State(initialValue: min(max(cents.wrappedValue / 100, 0), maxReais))
        self._centavos = State(initialValue: max(cents.wrappedValue % 100, 0))
    }

    var body: some View {
        HStack(spacing: 4) {
            Picker("Reais", selection: $reais) {
                ForEach(0...maxReais, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .labelsHidden()

            Text(",")
                .font(.title3.bold())

            Picker("Centavos", selection: $centavos) {
                ForEach(0..<100, id: \.self) { value in
                    Text(String(format: "%02d", value)).tag(value)
                }
            }
            .labelsHidden()
        }
        .navigationTitle(title)
        .onChange(of: reais) { _, _ in syncToBinding() }
        .onChange(of: centavos) { _, _ in syncToBinding() }
    }

    private func syncToBinding() {
        cents = (reais * 100) + centavos
    }
}

struct WatchLitersPickerView: View {
    @Binding var milliLiters: Int
    let title: String
    let maxLiters: Int

    @State private var whole: Int
    @State private var digit1: Int
    @State private var digit2: Int
    @State private var digit3: Int

    init(milliLiters: Binding<Int>, title: String, maxLiters: Int) {
        self._milliLiters = milliLiters
        self.title = title
        self.maxLiters = maxLiters

        let value = max(milliLiters.wrappedValue, 0)
        self._whole = State(initialValue: min(value / 1_000, maxLiters))
        self._digit1 = State(initialValue: (value / 100) % 10)
        self._digit2 = State(initialValue: (value / 10) % 10)
        self._digit3 = State(initialValue: value % 10)
    }

    var body: some View {
        HStack(spacing: 2) {
            Picker("Litros", selection: $whole) {
                ForEach(0...maxLiters, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
            .labelsHidden()

            Text(",")
                .font(.title3.bold())

            digitPicker($digit1)
            digitPicker($digit2)
            digitPicker($digit3)
        }
        .navigationTitle(title)
        .onChange(of: whole) { _, _ in syncToBinding() }
        .onChange(of: digit1) { _, _ in syncToBinding() }
        .onChange(of: digit2) { _, _ in syncToBinding() }
        .onChange(of: digit3) { _, _ in syncToBinding() }
    }

    private func digitPicker(_ selection: Binding<Int>) -> some View {
        Picker("", selection: selection) {
            ForEach(0..<10, id: \.self) { value in
                Text("\(value)").tag(value)
            }
        }
        .labelsHidden()
        .frame(width: 36)
    }

    private func syncToBinding() {
        milliLiters = (whole * 1_000) + (digit1 * 100) + (digit2 * 10) + digit3
    }
}

struct WatchOdometerPickerView: View {
    @Binding var odometer: Int
    let title: String
    let range: ClosedRange<Int>

    var body: some View {
        Picker(title, selection: $odometer) {
            ForEach(Array(range), id: \.self) { value in
                Text("\(value) km").tag(value)
            }
        }
        .labelsHidden()
        .navigationTitle(title)
    }
}

enum WatchNumberFormatting {
    static func currency(cents: Int) -> String {
        let reais = Double(cents) / 100.0
        return String(format: "R$ %.2f", reais).replacingOccurrences(of: ".", with: ",")
    }

    static func liters(milliLiters: Int) -> String {
        let value = Double(milliLiters) / 1000.0
        return String(format: "%.3f L", value).replacingOccurrences(of: ".", with: ",")
    }
}
