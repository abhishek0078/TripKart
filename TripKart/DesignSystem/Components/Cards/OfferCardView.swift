import SwiftUI

struct OfferCardView: View {

    let offer: Offer

    var body: some View {
        HStack(spacing: 0) {
            // Discount panel
            VStack {
                Text(offer.discount)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .frame(width: 86)
            .frame(maxHeight: .infinity)
            .background(Color(hex: offer.colorHex))

            // Details
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(offer.code)
                    .font(Font.App.captionMedium)
                    .foregroundStyle(Color.App.textPrimary)
                    .lineLimit(1)

                Text(offer.description)
                    .font(Font.App.small)
                    .foregroundStyle(Color.App.textSecondary)
                    .lineLimit(2)

                Spacer()

                Text("Valid till \(offer.validUntil)")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.App.textTertiary)
            }
            .padding(Spacing.sm)

            Spacer(minLength: 0)
        }
        .frame(width: 260, height: 88)
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.medium)
                .stroke(Color.App.border, lineWidth: 0.5)
        )
    }
}

#Preview {
    OfferCardView(offer: Offer(
        id: "1",
        title: "TRIPKART30",
        description: "30% off on your first bus booking",
        code: "TRIPKART30",
        discount: "30% OFF",
        validUntil: "31 Jul 2026",
        colorHex: "#2E80F7"
    ))
    .padding()
}
