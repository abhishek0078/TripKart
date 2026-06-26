import Foundation

struct PopularDestination: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let state: String
    let systemIcon: String
    let category: String
}
