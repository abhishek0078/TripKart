import SwiftUI

@Observable
private final class ReviewBookingViewModel {
    var coupons: [Coupon] = []
    var couponCode: String = ""
    var isApplyingCoupon = false
    var couponError: String?
    var isCouponSheetPresented = false
    var viewState: ViewState = .idle

    private let couponRepository: any CouponRepository

    init(couponRepository: any CouponRepository) {
        self.couponRepository = couponRepository
    }

    func loadCoupons() async {
        coupons = (try? await couponRepository.fetchCoupons()) ?? []
    }

    func applyCode(_ code: String, amount: Int) async -> Coupon? {
        isApplyingCoupon = true
        couponError = nil
        defer { isApplyingCoupon = false }
        do {
            return try await couponRepository.validate(code: code, amount: amount)
        } catch let error as AppError {
            couponError = error.errorDescription
            return nil
        } catch {
            couponError = "Invalid coupon."
            return nil
        }
    }
}

struct ReviewBookingView: View {
    @Environment(BookingCoordinator.self) private var coordinator
    @Environment(BookingEngine.self) private var bookingEngine
    @State private var viewModel: ReviewBookingViewModel

    init(couponRepository: any CouponRepository) {
        _viewModel = State(initialValue: ReviewBookingViewModel(couponRepository: couponRepository))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                tripSummarySection
                travellerSection
                couponSection
                FareCardView(
                    fare: bookingEngine.fareBreakdown,
                    passengers: bookingEngine.query.passengers,
                    outboundOperator: bookingEngine.outboundResult.operatorName,
                    returnOperator: bookingEngine.returnResult?.operatorName
                )
                .padding(.horizontal, Spacing.md)
            }
            .padding(.vertical, Spacing.md)
        }
        .background(Color.App.background)
        .navigationTitle("Review Booking")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.loadCoupons() }
        .sheet(isPresented: $viewModel.isCouponSheetPresented) {
            CouponPickerSheet(coupons: viewModel.coupons) { coupon in
                bookingEngine.applyCoupon(coupon)
                viewModel.couponCode = coupon.code
            }
        }
        .safeAreaInset(edge: .bottom) { proceedButton }
    }

    private var tripSummarySection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionHeader(bookingEngine.isRoundTrip ? "Outbound Journey" : "Trip Summary")
            tripCard(
                result: bookingEngine.outboundResult,
                origin: bookingEngine.query.origin.name,
                destination: bookingEngine.query.destination.name,
                date: bookingEngine.query.travelDate
            )
            if bookingEngine.isRoundTrip, let ret = bookingEngine.returnResult {
                sectionHeader("Return Journey")
                    .padding(.top, Spacing.xs)
                tripCard(
                    result: ret,
                    origin: bookingEngine.query.destination.name,
                    destination: bookingEngine.query.origin.name,
                    date: bookingEngine.query.returnDate ?? bookingEngine.query.travelDate
                )
            }
        }
    }

    private func tripCard(result: TripResult, origin: String, destination: String, date: Date) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(origin) → \(destination)")
                    .font(Font.App.bodyMedium).foregroundStyle(Color.App.textPrimary)
                Text(date.formatted(.dateTime.day().month(.abbreviated).year()))
                    .font(Font.App.caption).foregroundStyle(Color.App.textSecondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(result.operatorName)
                    .font(Font.App.caption).foregroundStyle(Color.App.textSecondary)
                Text("\(result.departureTime) → \(result.arrivalTime)")
                    .font(Font.App.captionMedium).foregroundStyle(Color.App.textPrimary)
            }
        }
        .padding(Spacing.md)
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .padding(.horizontal, Spacing.md)
    }

    private var travellerSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionHeader("Travellers")
            ForEach(bookingEngine.travellers.indices, id: \.self) { i in
                let outSeat = bookingEngine.outboundSeats.indices.contains(i) ? bookingEngine.outboundSeats[i] : nil
                let retSeat = bookingEngine.returnSeats.indices.contains(i) ? bookingEngine.returnSeats[i] : nil
                TravellerCardView(
                    traveller: bookingEngine.travellers[i],
                    index: i,
                    outboundSeat: outSeat,
                    returnSeat: retSeat
                )
                .padding(.horizontal, Spacing.md)
            }
        }
    }

    private var couponSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionHeader("Coupon")
            VStack(spacing: Spacing.sm) {
                if let applied = bookingEngine.appliedCoupon {
                    HStack {
                        Image(systemName: "tag.fill")
                            .foregroundStyle(Color.App.success)
                        Text(applied.code)
                            .font(Font.App.bodyMedium)
                            .foregroundStyle(Color.App.success)
                        Text("applied")
                            .font(Font.App.caption)
                            .foregroundStyle(Color.App.textSecondary)
                        Spacer()
                        Button("Remove") {
                            bookingEngine.removeCoupon()
                            viewModel.couponCode = ""
                        }
                        .font(Font.App.captionMedium)
                        .foregroundStyle(Color.App.error)
                    }
                    .padding(Spacing.md)
                    .background(Color.App.success.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                } else {
                    HStack(spacing: Spacing.sm) {
                        TextField("Enter coupon code", text: $viewModel.couponCode)
                            .font(Font.App.body)
                            .textInputAutocapitalization(.characters)
                            .padding(Spacing.md)
                            .background(Color.App.surface)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.medium))

                        Button {
                            Task {
                                if let coupon = await viewModel.applyCode(
                                    viewModel.couponCode,
                                    amount: bookingEngine.fareBreakdown.subtotal
                                ) {
                                    bookingEngine.applyCoupon(coupon)
                                }
                            }
                        } label: {
                            if viewModel.isApplyingCoupon {
                                ProgressView().tint(.white)
                            } else {
                                Text("Apply")
                                    .font(Font.App.bodyMedium)
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 72, height: 44)
                        .background(Color.App.primary)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                        .disabled(viewModel.couponCode.isEmpty || viewModel.isApplyingCoupon)
                    }

                    if let err = viewModel.couponError {
                        Text(err)
                            .font(Font.App.caption)
                            .foregroundStyle(Color.App.error)
                    }

                    Button("View all coupons") {
                        viewModel.isCouponSheetPresented = true
                    }
                    .font(Font.App.captionMedium)
                    .foregroundStyle(Color.App.primary)
                }
            }
            .padding(.horizontal, Spacing.md)
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(Font.App.headline)
            .foregroundStyle(Color.App.textPrimary)
            .padding(.horizontal, Spacing.md)
    }

    private var proceedButton: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("₹\(bookingEngine.fareBreakdown.total)")
                        .font(Font.App.price)
                        .foregroundStyle(Color.App.primary)
                    if bookingEngine.fareBreakdown.discount > 0 {
                        Text("Saved ₹\(bookingEngine.fareBreakdown.discount)")
                            .font(Font.App.caption)
                            .foregroundStyle(Color.App.success)
                    }
                }
                Spacer()
                Button {
                    coordinator.navigateToPayment()
                } label: {
                    Text("Proceed to Pay")
                        .font(Font.App.button)
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.xl)
                        .padding(.vertical, Spacing.md)
                        .background(Color.App.primary)
                        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                }
            }
            .padding(Spacing.md)
            .background(Color.App.background)
        }
    }
}
