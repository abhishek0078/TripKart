import Foundation

struct CouponsResponse: Codable {
    let coupons: [Coupon]
}

struct LocalCouponDataSource {
    func fetchAll() async throws -> [Coupon] {
        guard let url = Bundle.main.url(forResource: "coupons", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        return try JSONDecoder().decode(CouponsResponse.self, from: data).coupons
    }
}
