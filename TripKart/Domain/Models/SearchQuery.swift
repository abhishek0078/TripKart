import Foundation

enum TripType: String, CaseIterable, Hashable, Sendable {
    case oneWay    = "One Way"
    case roundTrip = "Round Trip"
}

struct SearchQuery: Hashable, Sendable {
    let pluginType: String
    let origin: SearchLocation
    let destination: SearchLocation
    let travelDate: Date
    let returnDate: Date?
    let passengers: Int
    let tripType: TripType
}
