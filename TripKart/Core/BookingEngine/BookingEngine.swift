import Foundation

@Observable
final class BookingEngine {
    let outboundResult: TripResult
    var returnResult: TripResult?
    let plugin: any SearchPlugin
    let query: SearchQuery

    var travellers: [Traveller] = []
    var outboundSeats: [String] = []
    var returnSeats: [String] = []
    var selectedCabinClass: String = "Economy"
    var returnCabinClass: String = "Economy"
    var appliedCoupon: Coupon?

    private let fareEngine = FareEngine()

    var isRoundTrip: Bool { query.tripType == .roundTrip && plugin.supportsTripType }

    var fareBreakdown: FareBreakdown {
        fareEngine.calculate(
            outboundPrice: outboundResult.price,
            returnPrice: returnResult?.price,
            passengers: query.passengers,
            pluginType: outboundResult.pluginType,
            coupon: appliedCoupon
        )
    }

    init(outboundResult: TripResult, plugin: any SearchPlugin, query: SearchQuery) {
        self.outboundResult = outboundResult
        self.plugin = plugin
        self.query = query
    }

    func applyCoupon(_ coupon: Coupon) { appliedCoupon = coupon }
    func removeCoupon() { appliedCoupon = nil }

    func buildBooking(id: String) -> Booking {
        Booking(
            id: id,
            outboundResult: outboundResult,
            returnResult: returnResult,
            travellers: travellers,
            outboundSeats: outboundSeats,
            returnSeats: returnSeats,
            fareBreakdown: fareBreakdown,
            couponCode: appliedCoupon?.code,
            status: .confirmed,
            createdAt: Date()
        )
    }
}
