import SwiftUI
import Factory

struct OdometerReminderListView: View {
    let vehicle: Vehicle
    @State private var reminders: [OdometerReminder] = []
    @State private var target = ""
    @State private var delay: OdometerReminderDelay = .immediate
    @State private var showAdd = false
    @Injected(\.odometerReminderRepository) private var repository

    var body: some View {
        NavigationStack {
            List {
                ForEach(reminders, id: \.clientId) { reminder in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(reminder.targetOdometer) km").font(.headline)
                        Text(reminder.status == .active ? "Notificar: \(reminder.notificationDelay.title)" : "Concluído") .foregroundStyle(.secondary)
                    }
                    .swipeActions { Button(role: .destructive) { Task { await repository.delete(reminder: reminder); await load() } } label: { Label("Excluir", systemImage: "trash") } }
                }
            }
            .overlay { if reminders.isEmpty { ContentUnavailableView("Nenhum lembrete", systemImage: "bell", description: Text("Adicione uma quilometragem para acompanhar.")) } }
            .navigationTitle("Lembretes")
            .toolbar { Button { showAdd = true } label: { Image(systemName: "plus") } }
            .task { await load() }
            .sheet(isPresented: $showAdd) {
                NavigationStack { Form { TextField("Quilometragem", text: $target).keyboardType(.numberPad); Picker("Notificar", selection: $delay) { ForEach(OdometerReminderDelay.allCases) { Text($0.title).tag($0) } } }.navigationTitle("Novo lembrete").toolbar { Button("Salvar") { guard let value = Int(target), value > 0 else { return }; let reminder = OdometerReminder(vehicleId: vehicle.clientId, targetOdometer: value, notificationDelay: delay); Task { _ = await repository.save(reminder: reminder); await OdometerReminderNotificationService.shared.requestAuthorization(); showAdd = false; target = ""; await load() } } } }
            }
        }
    }

    private func load() async { reminders = await repository.fetchData(vehicleId: vehicle.clientId) }
}
