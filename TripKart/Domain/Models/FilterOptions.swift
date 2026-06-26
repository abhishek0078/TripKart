import Foundation

struct FilterOptions: Equatable {
    var maxPrice: Int = Int.max
    var minRating: Double = 0
    var maxStops: Int = Int.max
    var selectedOperators: Set<String> = []

    var isDefault: Bool {
        maxPrice == Int.max &&
        minRating == 0 &&
        maxStops == Int.max &&
        selectedOperators.isEmpty
    }

    var activeFilterCount: Int {
        var count = 0
        if maxPrice != Int.max { count += 1 }
        if minRating > 0 { count += 1 }
        if maxStops != Int.max { count += 1 }
        if !selectedOperators.isEmpty { count += 1 }
        return count
    }
}
