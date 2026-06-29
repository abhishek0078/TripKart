import Foundation

struct Offer: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let title: String
    let description: String
    let code: String
    let discount: String
    let validUntil: String
    let colorHex: String
    let travelType: String  // "bus" | "flight" | "any"
}
