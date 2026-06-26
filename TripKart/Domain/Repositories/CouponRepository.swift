import Foundation

protocol CouponRepository {
    func fetchCoupons() async throws -> [Coupon]
    func validate(code: String, amount: Int) async throws -> Coupon
}
