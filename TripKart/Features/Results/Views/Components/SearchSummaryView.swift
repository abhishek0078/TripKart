import SwiftUI

struct SearchSummaryView: View {
    let query: SearchQuery
    let onModify: () -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: Spacing.xs) {
                    Text(query.origin.code)
                        .font(Font.App.headline)
                        .foregroundStyle(Color.App.textPrimary)
                    Image(systemName: "arrow.right")
                        .font(Font.App.caption)
                        .foregroundStyle(Color.App.textSecondary)
                    Text(query.destination.code)
                        .font(Font.App.headline)
                        .foregroundStyle(Color.App.textPrimary)
                }
                HStack(spacing: Spacing.xs) {
                    Text(query.travelDate.formatted(.dateTime.day().month(.abbreviated).year()))
                        .font(Font.App.caption)
                        .foregroundStyle(Color.App.textSecondary)
                    Text("•")
                        .font(Font.App.caption)
                        .foregroundStyle(Color.App.textTertiary)
                    Text("\(query.passengers) \(query.passengers == 1 ? "Passenger" : "Passengers")")
                        .font(Font.App.caption)
                        .foregroundStyle(Color.App.textSecondary)
                    if query.tripType == .roundTrip {
                        Text("• Round Trip")
                            .font(Font.App.caption)
                            .foregroundStyle(Color.App.primary)
                    }
                }
            }
            Spacer()
            Button(action: onModify) {
                Text("Modify")
                    .font(Font.App.captionMedium)
                    .foregroundStyle(Color.App.primary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.App.primaryLight.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .background(Color.App.surface)
    }
}
