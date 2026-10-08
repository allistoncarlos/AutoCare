//
//  FuelAmountKeypadView.swift
//  AutoCare Watch App
//

import SwiftUI

struct FuelAmountKeypadView: View {
    @ObservedObject var viewModel: MileageFormViewModel
    let onContinue: () -> Void

    private let maxCents = 200_000

    var body: some View {
        VStack(spacing: 4) {
            WatchProgressDots(index: 0)

            Text(viewModel.totalCostLabel)
                .font(.system(.title3, design: .rounded).weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            Text("valor da bomba")
                .font(.caption2)
                .foregroundStyle(.secondary)

            Grid(horizontalSpacing: 4, verticalSpacing: 4) {
                GridRow {
                    digit(1)
                    digit(2)
                    digit(3)
                }
                GridRow {
                    digit(4)
                    digit(5)
                    digit(6)
                }
                GridRow {
                    digit(7)
                    digit(8)
                    digit(9)
                }
                GridRow {
                    keyButton(systemImage: "delete.left") {
                        viewModel.totalCostCents /= 10
                    }
                    digit(0)
                    Button("OK", action: onContinue)
                        .buttonStyle(.plain)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(WatchTheme.violet.opacity(viewModel.canContinueAmount ? 1 : 0.35), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .disabled(!viewModel.canContinueAmount)
                }
            }
        }
        .navigationTitle("Valor")
        .onAppear { viewModel.step = .amount }
    }

    private func digit(_ value: Int) -> some View {
        keyButton(title: "\(value)") {
            let next = (viewModel.totalCostCents * 10) + value
            guard next <= maxCents else { return }
            viewModel.totalCostCents = next
        }
    }

    private func keyButton(title: String? = nil, systemImage: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                if let title {
                    Text(title)
                        .font(.title3.weight(.medium))
                } else if let systemImage {
                    Image(systemName: systemImage)
                        .font(.body.weight(.semibold))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.primary.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
