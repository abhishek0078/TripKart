import SwiftUI

struct BookingFlowView: View {
    let tripResult: TripResult
    let plugin: any SearchPlugin
    let query: SearchQuery
    let couponRepository: any CouponRepository
    let resultsRepository: any ResultsRepository

    @Environment(\.dismiss) private var dismiss
    @State private var coordinator = BookingCoordinator()
    @State private var bookingEngine: BookingEngine

    init(
        tripResult: TripResult,
        plugin: any SearchPlugin,
        query: SearchQuery,
        couponRepository: any CouponRepository,
        resultsRepository: any ResultsRepository
    ) {
        self.tripResult = tripResult
        self.plugin = plugin
        self.query = query
        self.couponRepository = couponRepository
        self.resultsRepository = resultsRepository
        _bookingEngine = State(initialValue: BookingEngine(outboundResult: tripResult, plugin: plugin, query: query))
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
                    case .paymentPlaceholder:
                        PaymentPlaceholderView { dismiss() }
                    }
                }
        }
        .environment(coordinator)
        .environment(bookingEngine)
    }
}

private struct PaymentPlaceholderView: View {
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "creditcard.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.App.primary.opacity(0.5))
            Text("Payment")
                .font(Font.App.display).foregroundStyle(Color.App.textPrimary)
            Text("Payment gateway coming in the next phase.")
                .font(Font.App.body).foregroundStyle(Color.App.textSecondary)
                .multilineTextAlignment(.center)
            Spacer()
            PrimaryButton(title: "Back to Home", isLoading: false, action: onDone)
                .padding(.horizontal, Spacing.md)
        }
        .padding(.horizontal, Spacing.xl)
        .background(Color.App.background)
        .navigationTitle("Payment")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
    }
}
