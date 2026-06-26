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
    let travelDate: Date
    let returnDate: Date?
    let origin: SearchLocation
    let destination: SearchLocation

    var isRoundTrip: Bool { returnResult != nil }
    var isUpcoming: Bool  { travelDate >= Calendar.current.startOfDay(for: Date()) }
}
