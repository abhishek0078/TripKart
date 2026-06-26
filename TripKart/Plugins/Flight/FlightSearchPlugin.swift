import Foundation

struct FlightSearchPlugin: SearchPlugin {
    let pluginType         = "flight"
    let displayName        = "Flight"
    let maxPassengers      = 9
    let supportsTripType   = true
    let locationDataKey    = "airports"
    let originLabel        = "From"
    let destinationLabel   = "To"
    let seatSelectionType  = SeatSelectionType.cabinClass
    let taxRate            = 0.12
}
