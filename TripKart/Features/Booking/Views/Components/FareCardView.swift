import SwiftUI

struct FareCardView: View {
    let fare: FareBreakdown
    let passengers: Int
    var outboundOperator: String? = nil
    var returnOperator: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            if fare.isRoundTrip {
                fareRow(
                    "Outbound\(outboundOperator.map { " · \($0)" } ?? "") (\(passengers)×)",
                    value: fare.outboundFare
                )
                fareRow(
                    "Return\(returnOperator.map { " · \($0)" } ?? "") (\(passengers)×)",
                    value: fare.returnFare
                )
                Divider().padding(.vertical, Spacing.xs)
                fareRow("Base Fare", value: fare.baseFare, isBold: true)
            } else {
                fareRow("Base Fare (\(passengers) × ₹\(fare.baseFare / max(passengers, 1)))", value: fare.baseFare)
            }

            fareRow(fare.taxLabel, value: fare.taxes)

            if fare.discount > 0 {
                Divider().padding(.vertical, Spacing.xs)
                fareRow("Subtotal", value: fare.subtotal)
                fareRow("Coupon Discount", value: -fare.discount, color: Color.App.success)
            }

            Divider().padding(.vertical, Spacing.sm)

            HStack {
                Text("Total Amount")
                    .font(Font.App.headline).foregroundStyle(Color.App.textPrimary)
                Spacer()
                Text("₹\(fare.total)")
                    .font(Font.App.price).foregroundStyle(Color.App.primary)
            }
        }
        .padding(Spacing.md)
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
    }

    private func fareRow(_ label: String, value: Int, isBold: Bool = false, color: Color = Color.App.textPrimary) -> some View {
        HStack {
            Text(label)
                .font(isBold ? Font.App.bodyMedium : Font.App.body)
                .foregroundStyle(Color.App.textSecondary)
            Spacer()
            Text(value < 0 ? "-₹\(-value)" : "₹\(value)")
                .font(isBold ? Font.App.bodyMedium : Font.App.body)
                .foregroundStyle(color)
        }
        .padding(.vertical, 3)
    }
}
