import SwiftUI

struct DestinationCardView: View {

    let destination: PopularDestination

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            // Icon panel
            ZStack {
                RoundedRectangle(cornerRadius: Radius.medium)
                    .fill(Color.App.primary.opacity(0.10))
                    .frame(width: 120, height: 90)

                Image(systemName: destination.systemIcon)
                    .font(.system(size: 38, weight: .medium))
                    .foregroundStyle(Color.App.primary)
            }

            Text(destination.name)
                .font(Font.App.captionMedium)
                .foregroundStyle(Color.App.textPrimary)

            Text(destination.state)
                .font(Font.App.small)
                .foregroundStyle(Color.App.textSecondary)
                .lineLimit(1)

            Text(destination.category)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.App.primary)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.App.primary.opacity(0.10))
                .clipShape(Capsule())
        }
        .frame(width: 120)
    }
}

#Preview {
    DestinationCardView(destination: PopularDestination(
        id: "1",
        name: "Goa",
        state: "Goa",
        systemIcon: "sun.max.fill",
        category: "Beaches"
    ))
    .padding()
}
