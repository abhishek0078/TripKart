import SwiftUI

struct PaymentProcessingView: View {
    @Environment(BookingCoordinator.self) private var coordinator
    @Environment(BookingEngine.self)      private var bookingEngine
    @Environment(PaymentEngine.self)      private var paymentEngine

    let bookingRepository: any BookingRepository

    var body: some View {
        VStack(spacing: Spacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.App.primaryLight.opacity(0.12))
                    .frame(width: 120, height: 120)
                ProgressView()
                    .scaleEffect(2.2)
                    .tint(Color.App.primary)
            }

            VStack(spacing: Spacing.sm) {
                Text("Processing Payment")
                    .font(Font.App.headline)
                    .foregroundStyle(Color.App.textPrimary)
                Text("Please wait. Do not close the app.")
                    .font(Font.App.body)
                    .foregroundStyle(Color.App.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: Spacing.xs) {
                detailRow("Amount",  "₹\(bookingEngine.fareBreakdown.total)")
                detailRow("Method",  paymentEngine.selectedMethod.rawValue)
            }
            .padding(Spacing.md)
            .background(Color.App.surface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.large))
            .padding(.horizontal, Spacing.xl)

            Spacer()
        }
        .background(Color.App.background)
        .navigationTitle("Processing")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .task { await processAndNavigate() }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(Font.App.body)
                .foregroundStyle(Color.App.textSecondary)
            Spacer()
            Text(value)
                .font(Font.App.bodyMedium)
                .foregroundStyle(Color.App.textPrimary)
        }
    }

    private func processAndNavigate() async {
        let result = await paymentEngine.processPayment(amount: bookingEngine.fareBreakdown.total)

        if let result, result.status == .success {
            let booking = bookingEngine.buildBooking(id: result.transactionId)
            try? await bookingRepository.save(booking: booking)
            coordinator.navigateToPaymentSuccess(booking: booking)
        } else {
            let reason = result?.failureReason ?? "Payment failed. Please try again."
            coordinator.navigateToPaymentFailure(reason: reason)
        }
    }
}
