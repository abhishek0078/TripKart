import SwiftUI

struct CouponPickerSheet: View {
    let coupons: [Coupon]
    let onSelect: (Coupon) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(coupons) { coupon in
                Button {
                    onSelect(coupon)
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        HStack {
                            Text(coupon.code)
                                .font(Font.App.bodyMedium)
                                .foregroundStyle(Color.App.primary)
                                .padding(.horizontal, Spacing.sm)
                                .padding(.vertical, 4)
                                .background(Color.App.primaryLight.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: Radius.small))
                            Spacer()
                            Text(discountLabel(coupon))
                                .font(Font.App.headline)
                                .foregroundStyle(Color.App.success)
                        }
                        Text(coupon.title)
                            .font(Font.App.bodyMedium)
                            .foregroundStyle(Color.App.textPrimary)
                        Text(coupon.description)
                            .font(Font.App.caption)
                            .foregroundStyle(Color.App.textSecondary)
                        Text("Min. booking ₹\(coupon.minAmount)")
                            .font(Font.App.small)
                            .foregroundStyle(Color.App.textTertiary)
                    }
                    .padding(.vertical, Spacing.xs)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.App.background)
            }
            .listStyle(.plain)
            .background(Color.App.background)
            .navigationTitle("Apply Coupon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.App.primary)
                }
            }
        }
    }

    private func discountLabel(_ coupon: Coupon) -> String {
        coupon.discountType == "percent"
        ? "\(coupon.discountValue)% OFF"
        : "₹\(coupon.discountValue) OFF"
    }
}
