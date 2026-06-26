import Foundation

struct TripResult: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let pluginType: String
    let operatorName: String
    let operatorIcon: String
    let departureTime: String
    let arrivalTime: String
    let duration: String
    let price: Int
    let availableSeats: Int
    let rating: Double
    let stops: Int
    // Bus-specific
    let busType: String?
    // Flight-specific
    let flightNumber: String?
    let cabinClass: String?
}
