import Foundation

struct Traveller: Identifiable, Codable, Hashable, Sendable {
    var id: String
    var firstName: String
    var lastName: String
    var age: Int
    var gender: Gender
    var documentType: String
    var documentNumber: String

    var fullName: String { "\(firstName) \(lastName)" }

    enum Gender: String, Codable, CaseIterable, Sendable {
        case male   = "Male"
        case female = "Female"
        case other  = "Other"
    }
}
