import SwiftUI

struct BookingFlowView: View {
    let tripResult: TripResult
    let plugin: any SearchPlugin
    let query: SearchQuery
    let couponRepository: any CouponRepository
    let resultsRepository: any ResultsRepository
    let bookingRepository: any BookingRepository
    let paymentRepository: any PaymentRepository

    @Environment(\.dismiss) private var dismiss
    @State private var coordinator = BookingCoordinator()
    @State private var bookingEngine: BookingEngine
    @State private var paymentEngine: PaymentEngine

    init(
        tripResult: TripResult,
        plugin: any SearchPlugin,
        query: SearchQuery,
        couponRepository: any CouponRepository,
        resultsRepository: any ResultsRepository,
        bookingRepository: any BookingRepository,
        paymentRepository: any PaymentRepository
    ) {
        self.tripResult = tripResult
        self.plugin = plugin
        self.query = query
        self.couponRepository = couponRepository
        self.resultsRepository = resultsRepository
        self.bookingRepository = bookingRepository
        self.paymentRepository = paymentRepository
        _bookingEngine = State(initialValue: BookingEngine(outboundResult: tripResult, plugin: plugin, query: query))
        _paymentEngine = State(initialValue: PaymentEngine(repository: paymentRepository))
    }

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            TripDetailView()
                .navigationDestination(for: BookingDestination.self) { destination in
                    switch destination {
                    case .travellerForm:
                        TravellerFormView()
                    case .seatSelection(let isReturn):
                        SeatSelectionView(isReturn: isReturn)
                    case .returnFlightSelection:
                        ReturnFlightView(resultsRepository: resultsRepository)
                    case .reviewBooking:
                        ReviewBookingView(couponRepository: couponRepository)
                    case .payment:
                        PaymentMethodsView()
                    case .paymentProcessing:
                        PaymentProcessingView(bookingRepository: bookingRepository)
                    case .paymentSuccess(let booking):
                        PaymentSuccessView(booking: booking)
                    case .paymentFailure(let reason):
                        PaymentFailureView(reason: reason)
                    }
                }
        }
        .environment(coordinator)
        .environment(bookingEngine)
        .environment(paymentEngine)
        .onAppear { coordinator.onDismiss = { dismiss() } }
    }
}
