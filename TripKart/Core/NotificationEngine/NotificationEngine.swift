import Foundation
import UserNotifications

@Observable
final class NotificationEngine {
    var permissionGranted = false
    let repository = LocalNotificationRepository()

    // MARK: – Permission

    func requestPermission() async {
        let granted = (try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        await MainActor.run { permissionGranted = granted }
    }

    func checkPermission() async {
        let status = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
        await MainActor.run { permissionGranted = status == .authorized }
    }

    // MARK: – Booking events

    func handleBookingConfirmed(_ booking: Booking) async {
        // In-app notification
        let confirmId = "confirm-\(booking.id)"
        let inApp = InAppNotification(
            id: confirmId,
            type: .bookingConfirmed,
            title: "Booking Confirmed!",
            body: "\(booking.origin.code) → \(booking.destination.code)  ·  \(formatShort(booking.travelDate))  ·  ₹\(booking.fareBreakdown.total)",
            bookingId: booking.id,
            createdAt: Date(),
            isRead: false
        )
        try? await repository.add(inApp)

        // Local push (fires 1s later so user sees it as a real notification)
        if permissionGranted {
            scheduleLocal(
                id: confirmId,
                title: "Booking Confirmed! ✅",
                body: inApp.body,
                after: 1
            )
        }

        // Schedule 24h trip-reminder local push (no in-app entry added now —
        // the in-app reminder appears when the user opens the app near travel time)
        let reminderDate = booking.travelDate.addingTimeInterval(-24 * 3600)
        if reminderDate > Date(), permissionGranted {
            let comps = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: reminderDate
            )
            scheduleLocalCalendar(
                id: "reminder-\(booking.id)",
                title: "Trip Tomorrow 🚀",
                body: "\(booking.origin.code) → \(booking.destination.code) departs tomorrow. Have a great trip!",
                dateComponents: comps
            )
        }
    }

    // MARK: – Helpers

    private func scheduleLocal(id: String, title: String, body: String, after seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func scheduleLocalCalendar(id: String, title: String, body: String, dateComponents: DateComponents) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body  = body
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func formatShort(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f.string(from: date)
    }
}
