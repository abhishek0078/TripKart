import SwiftUI

struct BannerCarouselView: View {

    let banners: [Banner]
    @State private var currentIndex = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                BannerCardView(banner: banner)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .task {
            guard banners.count > 1 else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { break }
                withAnimation(.easeInOut(duration: AnimationDuration.normal)) {
                    currentIndex = (currentIndex + 1) % banners.count
                }
            }
        }
    }
}

private struct BannerCardView: View {
    let banner: Banner

    var body: some View {
        ZStack(alignment: .leading) {
            Color(hex: banner.colorHex)

            // Background icon (decorative)
            Image(systemName: banner.systemIcon)
                .font(.system(size: 120, weight: .bold))
                .foregroundStyle(.white.opacity(0.12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .padding(.trailing, -10)

            // Content
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(banner.title)
                    .font(Font.App.title)
                    .foregroundStyle(.white)

                Text(banner.subtitle)
                    .font(Font.App.caption)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(2)

                Spacer()

                Text(banner.actionLabel)
                    .font(Font.App.captionMedium)
                    .foregroundStyle(Color(hex: banner.colorHex))
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs)
                    .background(.white)
                    .clipShape(Capsule())
            }
            .padding(Spacing.lg)
        }
    }
}

#Preview {
    BannerCarouselView(banners: [
        Banner(id: "1", title: "Summer Sale", subtitle: "Up to 30% off", systemIcon: "bus.fill", colorHex: "#2E80F7", actionLabel: "Book Now"),
        Banner(id: "2", title: "Fly Smart", subtitle: "Flat ₹500 off", systemIcon: "airplane", colorHex: "#7C3AED", actionLabel: "Explore")
    ])
    .padding()
}
