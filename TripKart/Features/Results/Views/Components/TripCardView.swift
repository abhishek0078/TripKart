import SwiftUI

struct TripCardView: View {
    let result: TripResult

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: Spacing.md) {
                operatorBadge
                Spacer()
                priceSection
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)

            Divider()
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)

            HStack(spacing: 0) {
                timeColumn(time: result.departureTime, label: "Dep")
                Spacer()
                durationColumn
                Spacer()
                timeColumn(time: result.arrivalTime, label: "Arr")
            }
            .padding(.horizontal, Spacing.md)

            Divider()
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)

            HStack(spacing: Spacing.sm) {
                if let busType = result.busType {
                    chipView(busType, icon: "bus.fill")
                }
                if let flightNumber = result.flightNumber {
                    chipView(flightNumber, icon: "number")
                }
                if let cabin = result.cabinClass {
                    chipView(cabin, icon: "seat.fill")
                }
                if result.stops == 0 {
                    chipView("Direct", icon: "checkmark.circle.fill", color: Color.App.success)
                } else {
                    chipView("\(result.stops) Stop\(result.stops > 1 ? "s" : "")", icon: "arrow.triangle.branch")
                }
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", result.rating))
                        .font(Font.App.caption)
                        .foregroundStyle(Color.App.textSecondary)
                }
            }
            .padding(.horizontal, Spacing.md)
            .padding(.bottom, Spacing.md)
        }
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .shadow(color: .black.opacity(0.06), radius: Elevation.low, x: 0, y: 2)
    }

    private var operatorBadge: some View {
        HStack(spacing: Spacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: Radius.small)
                    .fill(Color.App.primaryLight.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: result.operatorIcon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color.App.primary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(result.operatorName)
                    .font(Font.App.bodyMedium)
                    .foregroundStyle(Color.App.textPrimary)
                Text("\(result.availableSeats) seats left")
                    .font(Font.App.caption)
                    .foregroundStyle(
                        result.availableSeats < 6 ? Color.App.error : Color.App.textSecondary
                    )
            }
        }
    }

    private var priceSection: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("₹\(result.price)")
                .font(Font.App.price)
                .foregroundStyle(Color.App.primary)
            Text("per person")
                .font(Font.App.small)
                .foregroundStyle(Color.App.textTertiary)
        }
    }

    private func timeColumn(time: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(time)
                .font(Font.App.headline)
                .foregroundStyle(Color.App.textPrimary)
            Text(label)
                .font(Font.App.small)
                .foregroundStyle(Color.App.textTertiary)
        }
    }

    private var durationColumn: some View {
        VStack(spacing: 4) {
            Text(result.duration)
                .font(Font.App.caption)
                .foregroundStyle(Color.App.textSecondary)
            GeometryReader { geo in
                ZStack {
                    Rectangle()
                        .fill(Color.App.border)
                        .frame(height: 1)
                    HStack {
                        Circle().fill(Color.App.border).frame(width: 5, height: 5)
                        Spacer()
                        Circle().fill(Color.App.border).frame(width: 5, height: 5)
                    }
                }
                .frame(width: geo.size.width)
                .frame(maxHeight: .infinity)
            }
            .frame(height: 8)
        }
        .frame(maxWidth: 120)
    }

    private func chipView(_ text: String, icon: String, color: Color = Color.App.textSecondary) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundStyle(color)
            Text(text)
                .font(Font.App.small)
                .foregroundStyle(color)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}
