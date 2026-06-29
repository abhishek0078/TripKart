import Foundation

struct Banner: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let systemIcon: String
    let colorHex: String
    let actionLabel: String
    let actionType: String   // "bus" | "flight" | "offers"
}
