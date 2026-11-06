import SwiftData
import SwiftUI

struct OdometerReminderListView: View {
    let vehicle: Vehicle
    let onVehiclePickerTap: () -> Void
    @Query(sort: \OdometerReminder.targetOdometer) private var reminders: [OdometerReminder]
    @Query(sort: \VehicleMileage.date, order: .reverse) private var mileages: [VehicleMileage]
    @State private var editing: OdometerReminder?
    @State private var showingNew = false
    @State private var errorMessage: String?

    private var visible: [OdometerReminder] {
        reminders.filter { ($0.vehicleId == vehicle.referenceId || $0.vehicleId == vehicle.clientId) && !$0.deleted }
    }
    private var odometer: Int {
        mileages.first { ($0.vehicleId == vehicle.referenceId || $0.vehicleId == vehicle.clientId) && !$0.deleted }?.odometer ?? vehicle.odometer
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: onVehiclePickerTap) {
                        Label(vehicle.name, systemImage: "car.fill")
                    }
                    Text("Odômetro registrado: \(odometer) km")
                        .foregroundStyle(.secondary)
                }
                if visible.isEmpty {
                    ContentUnavailableView("Nenhum lembrete", systemImage: "checklist",
                        description: Text("Cadastre o que você precisa fazer ao atingir uma quilometragem."))
                } else {
                    reminderSection("Pendentes", items: visible.filter { !$0.completed })
                    reminderSection("Concluídos", items: visible.filter { $0.completed })
                }
            }
            .brandScreen()
            .navigationTitle("Lembretes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Novo lembrete", systemImage: "plus") { showingNew = true }
                }
            }
            .sheet(isPresented: $showingNew) {
                OdometerReminderEditView(vehicleId: vehicle.clientId, reminder: nil)
            }
            .sheet(item: $editing) { reminder in
                OdometerReminderEditView(vehicleId: vehicle.referenceId, reminder: reminder)
            }
            .alert("Não foi possível salvar", isPresented: Binding(
                get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } }
            )) { Button("OK") { errorMessage = nil } } message: { Text(errorMessage ?? "") }
        }
    }

    @ViewBuilder
    private func reminderSection(_ title: String, items: [OdometerReminder]) -> some View {
        if !items.isEmpty {
            Section(title) {
                ForEach(items, id: \.clientId) { reminder in
                    HStack(spacing: 12) {
                        Button {
                            do { try OdometerReminderRepository.shared.setCompleted(reminder, !reminder.completed) }
                            catch { errorMessage = error.localizedDescription }
                        } label: {
                            Image(systemName: reminder.completed ? "checkmark.circle.fill" : "circle")
                                .font(.title2)
                        }
                        .buttonStyle(.borderless)
                        .accessibilityLabel(reminder.completed ? "Reabrir \(reminder.title)" : "Concluir \(reminder.title)")
                        Button { editing = reminder } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(reminder.title).foregroundStyle(.primary)
                                Text("\(reminder.targetOdometer) km · \(reminder.notificationMode == "alarm" ? "Alarme" : "Lembrete")")
                                    .font(.subheadline).foregroundStyle(.secondary)
                                if reminder.isDue(at: odometer) {
                                    Text(odometer >= reminder.targetOdometer ? "Quilometragem atingida" : "Dentro da antecedência")
                                        .font(.caption).foregroundStyle(.orange)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                    .swipeActions {
                        Button("Excluir", role: .destructive) {
                            do { try OdometerReminderRepository.shared.remove(reminder) }
                            catch { errorMessage = error.localizedDescription }
                        }
                    }
                }
            }
        }
    }
}

private struct OdometerReminderEditView: View {
    let vehicleId: String
    let reminder: OdometerReminder?
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var target = ""
    @State private var advance = "200"
    @State private var mode: ReminderNotificationMode = .reminder
    @State private var errorMessage: String?
    @State private var saving = false

    private var valid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && title.count <= 500
            && Int(target).map { $0 >= 0 && $0 <= 9_007_199_254_740_991 } == true
            && Int(advance).map { $0 >= 0 && $0 <= 9_007_199_254_740_991 } == true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("O que lembrar") {
                    TextField("Ex.: Calibrar pneus", text: $title, axis: .vertical)
                    TextField("Odômetro alvo (km)", text: $target).keyboardType(.numberPad)
                    TextField("Antecedência (km)", text: $advance).keyboardType(.numberPad)
                }
                Section {
                    Picker("Tipo de aviso", selection: $mode) {
                        ForEach(ReminderNotificationMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                } footer: {
                    Text("A cada abastecimento, avisaremos a partir de \(max(0, (Int(target) ?? 0) - (Int(advance) ?? 200))) km, até você concluir. Parar o alarme não conclui o lembrete.")
                }
            }
            .navigationTitle(reminder == nil ? "Novo lembrete" : "Editar lembrete")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { Task { await save() } }.disabled(!valid || saving)
                }
            }
            .interactiveDismissDisabled(saving)
            .onAppear {
                guard let reminder else { return }
                title = reminder.title
                target = String(reminder.targetOdometer)
                advance = String(reminder.advanceKm)
                mode = ReminderNotificationMode(rawValue: reminder.notificationMode) ?? .reminder
            }
            .alert("Aviso", isPresented: Binding(
                get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } }
            )) { Button("OK") { errorMessage = nil } } message: { Text(errorMessage ?? "") }
        }
    }

    @MainActor
    private func save() async {
        guard valid, let targetOdometer = Int(target), let advanceKm = Int(advance) else { return }
        saving = true
        defer { saving = false }
        do {
            var permissionMessage: String?
            do { try await ReminderAlertService.shared.authorize(mode) }
            catch { permissionMessage = error.localizedDescription }
            let result = reminder ?? OdometerReminder(vehicleId: vehicleId, title: title, targetOdometer: targetOdometer)
            ReminderAlertService.shared.cancel(result)
            result.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            result.targetOdometer = targetOdometer
            result.advanceKm = advanceKm
            result.notificationMode = mode.rawValue
            try OdometerReminderRepository.shared.save(result)
            if let permissionMessage {
                ReminderAlertService.shared.errorMessage = "Lembrete salvo. \(permissionMessage)"
            }
            dismiss()
        } catch { errorMessage = error.localizedDescription }
    }
}
