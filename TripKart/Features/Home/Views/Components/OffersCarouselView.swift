import SwiftUI

struct OffersCarouselView: View {

    let offers: [Offer]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Spacing.md) {
                ForEach(offers) { offer in
                    OfferCardView(offer: offer)
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }
}

#Preview {
    OffersCarouselView(offers: [
        Offer(id: "1", title: "TRIPKART30", description: "30% off first bus", code: "TRIPKART30", discount: "30% OFF", validUntil: "31 Jul 2026", colorHex: "#2E80F7"),
        Offer(id: "2", title: "FLYLOW500",  description: "₹500 off flights",  code: "FLYLOW500",  discount: "₹500 OFF", validUntil: "15 Jul 2026", colorHex: "#7C3AED")
    ])
}
