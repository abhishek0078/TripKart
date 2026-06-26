import Foundation

enum SeatSelectionType: Sendable {
    case seatGrid
    case cabinClass
}

protocol SearchPlugin: Sendable {
    var pluginType: String { get }
    var displayName: String { get }
    var maxPassengers: Int { get }
    var supportsTripType: Bool { get }
    var locationDataKey: String { get }
    var originLabel: String { get }
    var destinationLabel: String { get }
    var seatSelectionType: SeatSelectionType { get }
    var taxRate: Double { get }
}
