import Foundation

struct BusSearchPlugin: SearchPlugin {
    let pluginType         = "bus"
    let displayName        = "Bus"
    let maxPassengers      = 6
    let supportsTripType   = false
    let locationDataKey    = "cities"
    let originLabel        = "From"
    let destinationLabel   = "To"
    let seatSelectionType  = SeatSelectionType.seatGrid
    let taxRate            = 0.05
}
