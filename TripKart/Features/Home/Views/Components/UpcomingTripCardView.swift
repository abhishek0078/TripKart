import SwiftUI

struct UpcomingTripCardView: View {
    let booking: Booking

    private var daysUntilTrip: Int {
        let today   = Calendar.current.startOfDay(for: Date())
        let travel  = Calendar.current.startOfDay(for: booking.travelDate)
        return Calendar.current.dateComponents([.day], from: today, to: travel).day ?? 0
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Left – countdown
            VStack(spacing: 2) {
                Text("\(daysUntilTrip)")
                    .font(Font.App.display)
                    .foregroundStyle(Color.App.primary)
                Text("days")
                    .font(Font.App.small)
                    .foregroundStyle(Color.App.textTertiary)
            }
            .frame(width: 52)
            .padding(.vertical, Spacing.sm)
            .background(Color.App.primaryLight.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: Radius.medium))

            // Right – trip info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(booking.origin.code)
                        .font(Font.App.headline)
                        .foregroundStyle(Color.App.textPrimary)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.App.textTertiary)
                    Text(booking.destination.code)
                        .font(Font.App.headline)
                        .foregroundStyle(Color.App.textPrimary)
                    if booking.isRoundTrip {
                        Text("· Round Trip")
                            .font(Font.App.small)
                            .foregroundStyle(Color.App.primary)
                    }
                }
                Text(booking.travelDate.formatted(.dateTime.day().month(.wide).year()))
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
                HStack(spacing: Spacing.xs) {
                    Text(booking.outboundResult.operatorName)
                        .font(Font.App.small)
                        .foregroundStyle(Color.App.textTertiary)
                    Text("·")
                        .foregroundStyle(Color.App.textTertiary)
                    Text("\(booking.travellers.count) passenger\(booking.travellers.count == 1 ? "" : "s")")
                        .font(Font.App.small)
                        .foregroundStyle(Color.App.textTertiary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.App.textTertiary)
        }
        .padding(Spacing.md)
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.large)
                .stroke(Color.App.border.opacity(0.5), lineWidth: 1)
        )
    }
}
