import Foundation

struct FilterEngine {
    func filter(_ results: [TripResult], with options: FilterOptions) -> [TripResult] {
        results.filter { result in
            if result.price > options.maxPrice { return false }
            if result.rating < options.minRating { return false }
            if result.stops > options.maxStops { return false }
            if !options.selectedOperators.isEmpty,
               !options.selectedOperators.contains(result.operatorName) { return false }
            return true
        }
    }

    func availableOperators(from results: [TripResult]) -> [String] {
        Array(Set(results.map(\.operatorName))).sorted()
    }

    func priceRange(from results: [TripResult]) -> ClosedRange<Int> {
        let prices = results.map(\.price)
        let min = prices.min() ?? 0
        let max = prices.max() ?? Int.max
        return min...max
    }
}
