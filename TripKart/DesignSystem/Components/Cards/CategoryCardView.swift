import SwiftUI

struct CategoryCardView: View {

    let category: TravelCategory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                ZStack {
                    Circle()
                        .fill(category.isAvailable
                              ? Color.App.primary.opacity(0.12)
                              : Color.App.surface)
                        .frame(width: 60, height: 60)

                    Image(systemName: category.systemIcon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(category.isAvailable
                                         ? Color.App.primary
                                         : Color.App.textTertiary)
                }

                Text(category.name)
                    .font(Font.App.captionMedium)
                    .foregroundStyle(category.isAvailable
                                     ? Color.App.textPrimary
                                     : Color.App.textTertiary)

                if !category.isAvailable {
                    Text("Soon")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, Spacing.xs)
                        .padding(.vertical, 2)
                        .background(Color.App.textTertiary)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(!category.isAvailable)
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        CategoryCardView(
            category: TravelCategory(id: "1", name: "Bus", systemIcon: "bus.fill", pluginType: "bus", isAvailable: true),
            action: {}
        )
        CategoryCardView(
            category: TravelCategory(id: "2", name: "Train", systemIcon: "tram.fill", pluginType: "train", isAvailable: false),
            action: {}
        )
    }
    .padding()
}
