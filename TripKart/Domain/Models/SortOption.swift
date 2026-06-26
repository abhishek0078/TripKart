import Foundation

enum SortOption: String, CaseIterable, Hashable, Sendable {
    case price      = "Price"
    case duration   = "Duration"
    case departure  = "Departure"
    case arrival    = "Arrival"
    case rating     = "Rating"
}
