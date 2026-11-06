import Foundation
import SwiftData

@main
struct OdometerReminderTests {
    @MainActor
    static func main() throws {
        let reminder = OdometerReminder(vehicleId: "vehicle-a", title: "Calibrar pneus", targetOdometer: 1_000)
        assert(reminder.advanceKm == 200)
        assert(reminder.notificationMode == "reminder")
        for (odometer, due) in [(0, false), (799, false), (800, true), (999, true), (1_000, true), (1_001, true), (8_000, true)] {
            assert(reminder.isDue(at: odometer) == due, "Unexpected result at \(odometer)")
        }
        // A subsequent refuel remains eligible until explicit completion.
        assert(reminder.isDue(at: 1_200))
        assert(reminder.isDue(at: 1_500))
        reminder.completed = true
        assert(!reminder.isDue(at: 8_000))
        reminder.completed = false
        reminder.deleted = true
        assert(!reminder.isDue(at: 8_000))
        reminder.deleted = false
        reminder.advanceKm = 0
        assert(!reminder.isDue(at: 999))
        assert(reminder.isDue(at: 1_000))
        reminder.advanceKm = 2_000
        assert(reminder.isDue(at: 0))

        let schema = Schema([OdometerReminder.self])
        let container = try ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        context.insert(reminder)
        for index in 0..<150 {
            context.insert(OdometerReminder(vehicleId: "vehicle-b", title: "Item \(index)", targetOdometer: index))
        }
        try context.save()
        let count = try context.fetchCount(FetchDescriptor<OdometerReminder>())
        assert(count == 151)
        reminder.notificationMode = "alarm"
        reminder.synced = true
        let data = try JSONEncoder().encode(OdometerReminderRequest(reminder))
        let request = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        assert(request["notificationMode"] as? String == "alarm")
        assert(request["id"] == nil && request["synced"] == nil && request["deleted"] == nil)
        let payload = OdometerReminderPayload(reminder)
        let roundTrip = try JSONDecoder().decode(OdometerReminderPayload.self, from: JSONEncoder().encode(payload)).model()
        assert(roundTrip.clientId == reminder.clientId)
        assert(roundTrip.notificationMode == "alarm")
        assert(roundTrip.advanceKm == 2_000)
        assert(roundTrip.synced)
        print("PASS: thresholds, repeated refuels, completion, deletion, custom advance, 151 persisted reminders, request and response round trip")
    }
}
