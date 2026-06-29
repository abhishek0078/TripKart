import SwiftUI

struct OffersCarouselView: View {
    let offers: [Offer]
    var onTap: ((Offer) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Spacing.md) {
                ForEach(offers) { offer in
                    Button { onTap?(offer) } label: {
                        OfferCardView(offer: offer)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.lg)
        }
    }
}
