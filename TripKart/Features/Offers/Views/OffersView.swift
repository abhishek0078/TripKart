import SwiftUI

struct OffersView: View {
    let homeRepository: any HomeRepository
    var onStartBooking: ((String) -> Void)? = nil
    @State private var offers: [Offer] = []
    @State private var isLoading = false
    @State private var selectedOffer: Offer?

    var body: some View {
        Group {
            if isLoading && offers.isEmpty {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(Color.App.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if offers.isEmpty {
                emptyState
            } else {
                offersList
            }
        }
        .navigationTitle("Offers & Coupons")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.App.background)
        .task { await loadOffers() }
        .sheet(item: $selectedOffer) { offer in
            OfferFullDetailView(offer: offer) { travelType in
                selectedOffer = nil
                onStartBooking?(travelType)
            }
        }
    }

    private var offersList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                Text("\(offers.count) offers available")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Spacing.lg)
                    .padding(.top, Spacing.sm)

                ForEach(offers) { offer in
                    OfferRowCard(offer: offer) {
                        selectedOffer = offer
                    }
                    .padding(.horizontal, Spacing.lg)
                }
            }
            .padding(.bottom, Spacing.xxl)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "tag")
                .font(.system(size: 64))
                .foregroundStyle(Color.App.primary.opacity(0.4))
            VStack(spacing: Spacing.xs) {
                Text("No Offers Right Now")
                    .font(Font.App.title)
                    .foregroundStyle(Color.App.textPrimary)
                Text("Check back soon for exclusive deals.")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
            }
            Spacer()
        }
    }

    private func loadOffers() async {
        isLoading = true
        defer { isLoading = false }
        offers = (try? await homeRepository.fetchOffers()) ?? []
    }
}

// MARK: – Row card (full-width)

private struct OfferRowCard: View {
    let offer: Offer
    let onTap: () -> Void
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Coloured header
            ZStack(alignment: .leading) {
                Color(hex: offer.colorHex)
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text(offer.discount)
                            .font(Font.App.title)
                            .foregroundStyle(.white)
                        Text(offer.title)
                            .font(Font.App.captionMedium)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    Spacer()
                    Image(systemName: "tag.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white.opacity(0.15))
                }
                .padding(Spacing.md)
            }
            .frame(height: 90)

            // Body
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(offer.description)
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
                    .lineLimit(2)

                HStack {
                    // Code pill
                    HStack(spacing: Spacing.xs) {
                        Text(offer.code)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(hex: offer.colorHex))
                            .lineLimit(1)
                        Image(systemName: "scissors")
                            .font(.system(size: 10))
                            .foregroundStyle(Color(hex: offer.colorHex).opacity(0.6))
                    }
                    .padding(.horizontal, Spacing.sm)
                    .padding(.vertical, 5)
                    .background(Color(hex: offer.colorHex).opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                            .foregroundStyle(Color(hex: offer.colorHex).opacity(0.3))
                    )

                    Spacer()

                    // Copy button
                    Button {
                        UIPasteboard.general.string = offer.code
                        withAnimation(.spring(duration: 0.3)) { copied = true }
                        Task {
                            try? await Task.sleep(for: .seconds(2))
                            withAnimation { copied = false }
                        }
                    } label: {
                        Label(
                            copied ? "Copied!" : "Copy Code",
                            systemImage: copied ? "checkmark.circle.fill" : "doc.on.doc.fill"
                        )
                        .font(Font.App.captionMedium)
                        .foregroundStyle(copied ? Color.App.success : Color(hex: offer.colorHex))
                        .padding(.horizontal, Spacing.sm)
                        .padding(.vertical, 6)
                        .background((copied ? Color.App.success : Color(hex: offer.colorHex)).opacity(0.1))
                        .clipShape(Capsule())
                    }

                    // Details arrow
                    Button {
                        onTap()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.App.textTertiary)
                            .padding(8)
                            .background(Color.App.border.opacity(0.4))
                            .clipShape(Circle())
                    }
                }

                Text("Valid till \(offer.validUntil)")
                    .font(Font.App.small)
                    .foregroundStyle(Color.App.textTertiary)
            }
            .padding(Spacing.md)
            .background(Color.App.surface)
        }
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

// MARK: – Full detail sheet

struct OfferFullDetailView: View {
    let offer: Offer
    let onBookNow: (String) -> Void
    @State private var copied = false

    var body: some View {
        // No ScrollView — content is short enough for any detent. Spacer pushes
        // the button to the bottom without any gesture-recogniser conflicts.
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.App.border)
                .frame(width: 40, height: 4)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.sm)

            // Hero banner
            ZStack {
                RoundedRectangle(cornerRadius: Radius.large)
                    .fill(Color(hex: offer.colorHex))
                    .frame(height: 140)
                VStack(spacing: Spacing.xs) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.4))
                    Text(offer.discount)
                        .font(Font.App.title)
                        .foregroundStyle(.white)
                    Text(offer.title)
                        .font(Font.App.captionMedium)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.md)

            // Description
            Text(offer.description)
                .font(Font.App.body)
                .foregroundStyle(Color.App.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.md)

            // Code card
            VStack(spacing: Spacing.xs) {
                Text("COUPON CODE")
                    .font(Font.App.small)
                    .foregroundStyle(Color.App.textTertiary)
                    .kerning(1.5)

                HStack {
                    Text(offer.code)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(hex: offer.colorHex))
                    Spacer()
                    Button {
                        UIPasteboard.general.string = offer.code
                        withAnimation(.spring(duration: 0.3)) { copied = true }
                        Task {
                            try? await Task.sleep(for: .seconds(2))
                            withAnimation { copied = false }
                        }
                    } label: {
                        Label(
                            copied ? "Copied!" : "Copy",
                            systemImage: copied ? "checkmark.circle.fill" : "doc.on.doc"
                        )
                        .font(Font.App.captionMedium)
                        .foregroundStyle(copied ? Color.App.success : Color(hex: offer.colorHex))
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                        .background((copied ? Color.App.success : Color(hex: offer.colorHex)).opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                .padding(Spacing.md)
                .background(Color(hex: offer.colorHex).opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                .overlay(
                    RoundedRectangle(cornerRadius: Radius.medium)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                        .foregroundStyle(Color(hex: offer.colorHex).opacity(0.3))
                )
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.sm)

            Text("Valid till \(offer.validUntil)")
                .font(Font.App.caption)
                .foregroundStyle(Color.App.textTertiary)

            Spacer()

            // Button sits naturally above safe area — no ScrollView to fight with
            Divider()
            Button { onBookNow(offer.travelType) } label: {
                Text("Book Now — Use \(offer.code)")
                    .font(Font.App.button)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: offer.colorHex))
                    .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.md)
        }
        .background(Color.App.background)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }
}
