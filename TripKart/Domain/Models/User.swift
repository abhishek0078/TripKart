import Foundation

struct User: Codable, Identifiable, Equatable, Hashable, Sendable {
    let id: String
    let name: String
    let phone: String
    let email: String?
    let avatar: String?
}
