import Foundation

struct SearchLocation: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let name: String
    let subtitle: String
    let code: String
    let type: String
}
