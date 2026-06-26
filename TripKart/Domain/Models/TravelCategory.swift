import Foundation

struct TravelCategory: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let systemIcon: String
    let pluginType: String
    let isAvailable: Bool
}
