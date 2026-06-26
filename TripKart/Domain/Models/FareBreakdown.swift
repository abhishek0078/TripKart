import Foundation

struct FareBreakdown: Hashable, Sendable, Codable {
    let outboundFare: Int
    let returnFare: Int        // 0 for one-way
    let taxes: Int
    let taxLabel: String
    let discount: Int
    let total: Int

    var baseFare: Int   { outboundFare + returnFare }
    var subtotal: Int   { baseFare + taxes }
    var isRoundTrip: Bool { returnFare > 0 }
}
