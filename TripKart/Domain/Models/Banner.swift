import Foundation

struct Banner: Identifiable, Codable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let systemIcon: String
    let colorHex: String
    let actionLabel: String
}
