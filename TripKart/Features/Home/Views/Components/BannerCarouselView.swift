import SwiftUI

struct BannerCarouselView: View {
    let banners: [Banner]
    var onTap: ((Banner) -> Void)?
    @State private var currentIndex = 0

    var body: some View {
        VStack(spacing: Spacing.sm) {
            TabView(selection: $currentIndex) {
                ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                    Button { onTap?(banner) } label: {
                        BannerCardView(banner: banner)
                    }
                    .buttonStyle(.plain)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
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

            // Custom dots — outside the tappable banner area so they never intercept taps
            HStack(spacing: 6) {
                ForEach(banners.indices, id: \.self) { i in
                    Capsule()
                        .fill(i == currentIndex ? Color.App.primary : Color.App.border)
                        .frame(width: i == currentIndex ? 20 : 6, height: 6)
                        .animation(.easeInOut(duration: AnimationDuration.fast), value: currentIndex)
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

            Image(systemName: banner.systemIcon)
                .font(.system(size: 120, weight: .bold))
                .foregroundStyle(.white.opacity(0.12))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .padding(.trailing, -10)

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
