import Foundation

struct SortEngine {
    func sort(_ results: [TripResult], by option: SortOption) -> [TripResult] {
        switch option {
        case .price:
            return results.sorted { $0.price < $1.price }
        case .duration:
            return results.sorted { parseDuration($0.duration) < parseDuration($1.duration) }
        case .departure:
            return results.sorted { $0.departureTime < $1.departureTime }
        case .arrival:
            return results.sorted { $0.arrivalTime < $1.arrivalTime }
        case .rating:
            return results.sorted { $0.rating > $1.rating }
        }
    }

    private func parseDuration(_ duration: String) -> Int {
        let parts = duration.components(separatedBy: CharacterSet(charactersIn: "hm ")).compactMap(Int.init)
        guard parts.count >= 2 else { return 0 }
        return parts[0] * 60 + parts[1]
    }
}
