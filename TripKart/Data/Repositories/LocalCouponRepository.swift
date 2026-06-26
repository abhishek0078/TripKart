import Foundation

struct LocalCouponRepository: CouponRepository {
    private let dataSource = LocalCouponDataSource()

    func fetchCoupons() async throws -> [Coupon] {
        try await dataSource.fetchAll()
    }

    func validate(code: String, amount: Int) async throws -> Coupon {
        let coupons = try await fetchCoupons()
        guard let coupon = coupons.first(where: { $0.code.uppercased() == code.uppercased() }) else {
            throw AppError.unknown("Invalid coupon code.")
        }
        if amount < coupon.minAmount {
            throw AppError.unknown("Minimum booking amount ₹\(coupon.minAmount) required.")
        }
        return coupon
    }
}
