import Foundation

struct Coupon: Identifiable, Codable, Hashable, Sendable {
    let id: String
    let code: String
    let title: String
    let description: String
    let discountType: String   // "percent" or "flat"
    let discountValue: Int
    let maxDiscount: Int
    let minAmount: Int
}
