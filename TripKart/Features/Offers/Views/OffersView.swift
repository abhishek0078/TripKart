import SwiftUI

struct OffersView: View {
    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()

            Image(systemName: "tag")
                .font(.system(size: 64))
                .foregroundStyle(Color.App.primary.opacity(0.4))

            VStack(spacing: Spacing.xs) {
                Text("Offers & Coupons")
                    .font(Font.App.title)
                    .foregroundStyle(Color.App.textPrimary)

                Text("Exclusive deals and discount codes\nwill appear here.")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
        .navigationTitle("Offers")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview { OffersView() }
