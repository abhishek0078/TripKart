import SwiftUI

struct BookingCardView: View {
    let booking: Booking

    var body: some View {
        VStack(spacing: 0) {
            // Header row — route + status
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(booking.origin.code)
                            .font(Font.App.title)
                            .foregroundStyle(Color.App.textPrimary)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.App.textTertiary)
                        Text(booking.destination.code)
                            .font(Font.App.title)
                            .foregroundStyle(Color.App.textPrimary)
                        if booking.isRoundTrip {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.system(size: 10))
                                .foregroundStyle(Color.App.primary)
                        }
                    }
                    Text("\(booking.origin.name) to \(booking.destination.name)")
                        .font(Font.App.caption)
                        .foregroundStyle(Color.App.textSecondary)
                }
                Spacer()
                statusBadge
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.sm)

            Divider().padding(.horizontal, Spacing.md)

            // Journey details
            HStack(spacing: 0) {
                journeyColumn(
                    time: booking.outboundResult.departureTime,
                    label: booking.travelDate.formatted(.dateTime.day().month(.abbreviated)),
                    sub: booking.outboundResult.operatorName
                )
                Spacer()
                VStack(spacing: 2) {
                    Text(booking.outboundResult.duration)
                        .font(Font.App.small)
                        .foregroundStyle(Color.App.textTertiary)
                    Image(systemName: "airplane")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.App.border)
                    Text(booking.outboundResult.stops == 0 ? "Direct" : "\(booking.outboundResult.stops) Stop")
                        .font(Font.App.small)
                        .foregroundStyle(booking.outboundResult.stops == 0 ? Color.App.success : Color.App.warning)
                }
                Spacer()
                journeyColumn(
                    time: booking.outboundResult.arrivalTime,
                    label: "\(booking.travellers.count) Pax",
                    sub: "₹\(booking.fareBreakdown.total)"
                )
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)

            // Seat chips
            if !booking.outboundSeats.isEmpty {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: "chair.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.App.textTertiary)
                    ForEach(booking.outboundSeats.prefix(4), id: \.self) { seat in
                        Text(seat)
                            .font(Font.App.small)
                            .foregroundStyle(Color.App.primary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.App.primaryLight.opacity(0.12))
                            .clipShape(Capsule())
                    }
                    if booking.outboundSeats.count > 4 {
                        Text("+\(booking.outboundSeats.count - 4)")
                            .font(Font.App.small)
                            .foregroundStyle(Color.App.textTertiary)
                    }
                    Spacer()
                    Text(booking.id)
                        .font(Font.App.small)
                        .foregroundStyle(Color.App.textTertiary)
                        .lineLimit(1)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.md)
            } else {
                HStack {
                    Spacer()
                    Text(booking.id)
                        .font(Font.App.small)
                        .foregroundStyle(Color.App.textTertiary)
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.md)
            }
        }
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .overlay(
            RoundedRectangle(cornerRadius: Radius.large)
                .stroke(Color.App.border.opacity(0.5), lineWidth: 1)
        )
    }

    private var statusBadge: some View {
        Text(booking.status.rawValue)
            .font(Font.App.small)
            .foregroundStyle(badgeForeground)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(badgeBackground)
            .clipShape(Capsule())
    }

    private var badgeForeground: Color {
        switch booking.status {
        case .confirmed: return Color.App.success
        case .pending:   return Color.App.warning
        case .cancelled: return Color.App.error
        }
    }

    private var badgeBackground: Color { badgeForeground.opacity(0.12) }

    private func journeyColumn(time: String, label: String, sub: String) -> some View {
        VStack(spacing: 2) {
            Text(time)
                .font(Font.App.headline)
                .foregroundStyle(Color.App.textPrimary)
            Text(label)
                .font(Font.App.caption)
                .foregroundStyle(Color.App.textSecondary)
            Text(sub)
                .font(Font.App.small)
                .foregroundStyle(Color.App.textTertiary)
        }
    }
}
