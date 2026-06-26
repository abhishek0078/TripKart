import SwiftUI

struct TravellerCardView: View {
    let traveller: Traveller
    let index: Int
    var outboundSeat: String? = nil
    var returnSeat: String? = nil

    var body: some View {
        HStack(spacing: Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.App.primaryLight.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(initials)
                    .font(Font.App.bodyMedium)
                    .foregroundStyle(Color.App.primary)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(traveller.fullName)
                    .font(Font.App.bodyMedium)
                    .foregroundStyle(Color.App.textPrimary)
                Text("\(traveller.gender.rawValue) · \(traveller.age) yrs")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
                if outboundSeat != nil || returnSeat != nil {
                    HStack(spacing: Spacing.sm) {
                        if let s = outboundSeat {
                            seatChip("↗ \(s)", color: Color.App.primary)
                        }
                        if let s = returnSeat {
                            seatChip("↙ \(s)", color: Color.App.warning)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
    }

    private func seatChip(_ label: String, color: Color) -> some View {
        Text(label)
            .font(Font.App.small)
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
    }

    private var initials: String {
        "\(traveller.firstName.prefix(1).uppercased())\(traveller.lastName.prefix(1).uppercased())"
    }
}
