import Foundation

enum BookingStatus: String, Codable, Sendable {
    case pending   = "Pending"
    case confirmed = "Confirmed"
    case cancelled = "Cancelled"
}

struct Booking: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let outboundResult: TripResult
    let returnResult: TripResult?
    let travellers: [Traveller]
    let outboundSeats: [String]
    let returnSeats: [String]
    let fareBreakdown: FareBreakdown
    let couponCode: String?
    let status: BookingStatus
    let createdAt: Date

    var isRoundTrip: Bool { returnResult != nil }
}
