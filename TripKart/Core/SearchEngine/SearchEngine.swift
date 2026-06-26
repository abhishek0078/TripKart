import Foundation

struct SearchEngine {
    func validate(query: SearchQuery, plugin: any SearchPlugin) -> Result<Void, AppError> {
        if query.origin.id == query.destination.id {
            return .failure(.unknown("Origin and destination cannot be the same."))
        }
        if query.passengers < 1 {
            return .failure(.unknown("At least 1 passenger is required."))
        }
        if query.passengers > plugin.maxPassengers {
            return .failure(.unknown("Maximum \(plugin.maxPassengers) passengers allowed."))
        }
        if plugin.supportsTripType, query.tripType == .roundTrip, query.returnDate == nil {
            return .failure(.unknown("Return date is required for round trip."))
        }
        return .success(())
    }
}
