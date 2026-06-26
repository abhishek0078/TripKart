import Foundation

enum PaymentStatus: String, Codable, Sendable {
    case success
    case failure
}

struct PaymentResult: Codable, Sendable {
    let transactionId: String
    let status: PaymentStatus
    let method: PaymentMethodType
    let amount: Int
    let failureReason: String?
}
