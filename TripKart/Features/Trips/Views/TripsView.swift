import SwiftUI

struct TripsView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            Image(systemName: "ticket")
                .font(.system(size: 64))
                .foregroundStyle(Color.App.primary.opacity(0.4))

            VStack(spacing: Spacing.xs) {
                Text("My Trips")
                    .font(Font.App.title)
                    .foregroundStyle(Color.App.textPrimary)

                Text("Your upcoming and past bookings\nwill appear here.")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .navigationTitle("My Trips")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview { TripsView() }
