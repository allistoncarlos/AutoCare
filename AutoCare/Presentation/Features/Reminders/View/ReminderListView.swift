import Factory
import SwiftUI

struct ReminderListView: View {
    @State private var reminders: [Reminder] = []
    @State private var showAdd = false
    @State private var title = ""
    @State private var description = ""
    @State private var hasDate = false
    @State private var dueDate = Date.now.addingTimeInterval(3600)
    @Injected(\.reminderRepository) private var repository

    var body: some View {
        NavigationStack {
            List {
                ForEach(reminders, id: \.clientId) { reminder in
                    HStack {
                        Button { Task { reminder.status = reminder.status == .pending ? .completed : .pending; reminder.completedAt = reminder.status == .completed ? .now : nil; reminder.synced = false; _ = await repository.save(reminder: reminder); if reminder.status == .completed { OdometerReminderNotificationService.shared.cancel(reminder: reminder) } else { OdometerReminderNotificationService.shared.schedule(reminder: reminder) }; await load() } } label: { Image(systemName: reminder.status == .completed ? "checkmark.circle.fill" : "circle").foregroundStyle(reminder.status == .completed ? .green : .secondary) }
                        VStack(alignment: .leading, spacing: 3) { Text(reminder.title).strikethrough(reminder.status == .completed); if !reminder.reminderDescription.isEmpty { Text(reminder.reminderDescription).font(.subheadline).foregroundStyle(.secondary).lineLimit(2) }; if let dueDate = reminder.dueDate { Text(dueDate, style: .date).font(.caption).foregroundStyle(.secondary) } }
                    }
                    .swipeActions { Button(role: .destructive) { Task { await repository.delete(reminder: reminder); OdometerReminderNotificationService.shared.cancel(reminder: reminder); await load() } } label: { Label("Excluir", systemImage: "trash") } }
                }
            }
            .overlay { if reminders.isEmpty { ContentUnavailableView("Nenhuma tarefa", systemImage: "checklist", description: Text("Crie um lembrete para não esquecer.")) } }
            .navigationTitle("Lembretes")
            .toolbar { Button { showAdd = true } label: { Image(systemName: "plus") } }
            .task { await load() }
            .sheet(isPresented: $showAdd) { addSheet }
        }
    }

    private var addSheet: some View {
        NavigationStack { Form { TextField("Título", text: $title); TextField("Descrição", text: $description, axis: .vertical); Toggle("Definir data", isOn: $hasDate); if hasDate { DatePicker("Quando", selection: $dueDate, in: Date.now...) } }.navigationTitle("Novo lembrete").toolbar { Button("Salvar") { guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }; let reminder = Reminder(title: title.trimmingCharacters(in: .whitespacesAndNewlines), reminderDescription: description, dueDate: hasDate ? dueDate : nil); Task { _ = await repository.save(reminder: reminder); await OdometerReminderNotificationService.shared.requestAuthorization(); OdometerReminderNotificationService.shared.schedule(reminder: reminder); title = ""; description = ""; hasDate = false; showAdd = false; await load() } } } }
    }

    private func load() async { reminders = await repository.fetchData() }
}
