import Foundation

struct FareEngine {
    func calculate(
        outboundPrice: Int,
        returnPrice: Int?,
        passengers: Int,
        pluginType: String,
        coupon: Coupon?
    ) -> FareBreakdown {
        let outboundFare = outboundPrice * passengers
        let returnFare   = (returnPrice ?? 0) * passengers
        let baseFare     = outboundFare + returnFare
        let taxRate      = pluginType == "flight" ? 0.12 : 0.05
        let taxLabel     = pluginType == "flight" ? "GST (12%)" : "Service Tax (5%)"
        let taxes        = Int(Double(baseFare) * taxRate)
        let subtotal     = baseFare + taxes

        var discount = 0
        if let coupon {
            switch coupon.discountType {
            case "percent":
                discount = min(Int(Double(subtotal) * Double(coupon.discountValue) / 100.0), coupon.maxDiscount)
            case "flat":
                discount = min(coupon.discountValue, coupon.maxDiscount)
            default: break
            }
        }

        return FareBreakdown(
            outboundFare: outboundFare,
            returnFare: returnFare,
            taxes: taxes,
            taxLabel: taxLabel,
            discount: discount,
            total: max(subtotal - discount, 0)
        )
    }
}
