import Foundation

enum NotificationType: String, Codable, Sendable, CaseIterable {
    case bookingConfirmed = "bookingConfirmed"
    case tripReminder     = "tripReminder"
    case promoAlert       = "promoAlert"

    var displayTitle: String {
        switch self {
        case .bookingConfirmed: return "Booking Confirmed"
        case .tripReminder:     return "Trip Reminder"
        case .promoAlert:       return "Promo Alert"
        }
    }

    var icon: String {
        switch self {
        case .bookingConfirmed: return "checkmark.seal.fill"
        case .tripReminder:     return "clock.fill"
        case .promoAlert:       return "tag.fill"
        }
    }

    var colorHex: String {
        switch self {
        case .bookingConfirmed: return "#059669"
        case .tripReminder:     return "#2E80F7"
        case .promoAlert:       return "#7C3AED"
        }
    }
}

struct InAppNotification: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let type: NotificationType
    let title: String
    let body: String
    let bookingId: String?
    let createdAt: Date
    var isRead: Bool
}
