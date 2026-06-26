import SwiftUI

struct PaymentFailureView: View {
    @Environment(BookingCoordinator.self) private var coordinator
    @Environment(BookingEngine.self)      private var bookingEngine
    @Environment(PaymentEngine.self)      private var paymentEngine

    let reason: String

    @State private var animate = false

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            // Animated failure badge
            ZStack {
                Circle()
                    .fill(Color.App.error.opacity(0.10))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animate ? 1.0 : 0.5)
                Circle()
                    .fill(Color.App.error.opacity(0.18))
                    .frame(width: 90, height: 90)
                Image(systemName: "xmark")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(Color.App.error)
                    .scaleEffect(animate ? 1.0 : 0.3)
                    .opacity(animate ? 1 : 0)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.65), value: animate)

            VStack(spacing: Spacing.xs) {
                Text("Payment Failed")
                    .font(Font.App.display)
                    .foregroundStyle(Color.App.textPrimary)
                Text(reason)
                    .font(Font.App.body)
                    .foregroundStyle(Color.App.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
            }

            VStack(spacing: Spacing.sm) {
                detailRow("Amount",  "₹\(bookingEngine.fareBreakdown.total)")
                Divider()
                detailRow("Method",  paymentEngine.selectedMethod.rawValue)
            }
            .padding(Spacing.md)
            .background(Color.App.surface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.large))
            .padding(.horizontal, Spacing.md)

            Spacer()

            VStack(spacing: Spacing.sm) {
                PrimaryButton(title: "Retry Payment", isLoading: false) {
                    coordinator.retryPayment()
                }
                .padding(.horizontal, Spacing.md)

                Button("Cancel Booking") {
                    coordinator.dismiss()
                }
                .font(Font.App.body)
                .foregroundStyle(Color.App.error)
                .padding(.bottom, Spacing.md)
            }
        }
        .background(Color.App.background)
        .navigationTitle("Payment Failed")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .onAppear { animate = true }
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
}
