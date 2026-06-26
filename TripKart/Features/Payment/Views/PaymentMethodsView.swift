import SwiftUI

struct PaymentMethodsView: View {
    @Environment(BookingCoordinator.self) private var coordinator
    @Environment(BookingEngine.self)      private var bookingEngine
    @Environment(PaymentEngine.self)      private var paymentEngine

    var body: some View {
        ScrollView {
            VStack(spacing: Spacing.md) {
                amountCard
                methodsList
                detailSection
            }
            .padding(.vertical, Spacing.md)
        }
        .background(Color.App.background)
        .navigationTitle("Payment")
        .navigationBarTitleDisplayMode(.large)
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom) { payButton }
    }

    // MARK: – Amount Card

    private var amountCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Payable")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
                Text("₹\(bookingEngine.fareBreakdown.total)")
                    .font(Font.App.display)
                    .foregroundStyle(Color.App.primary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(bookingEngine.query.passengers) Passenger(s)")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
                if bookingEngine.fareBreakdown.discount > 0 {
                    Text("Saved ₹\(bookingEngine.fareBreakdown.discount)")
                        .font(Font.App.captionMedium)
                        .foregroundStyle(Color.App.success)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.App.surface)
        .clipShape(RoundedRectangle(cornerRadius: Radius.large))
        .padding(.horizontal, Spacing.md)
    }

    // MARK: – Method Selector

    private var methodsList: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Select Payment Method")
                .font(Font.App.headline)
                .foregroundStyle(Color.App.textPrimary)
                .padding(.horizontal, Spacing.md)

            VStack(spacing: 0) {
                ForEach(PaymentMethodType.allCases, id: \.self) { method in
                    methodRow(method)
                    if method != PaymentMethodType.allCases.last {
                        Divider().padding(.horizontal, Spacing.md)
                    }
                }
            }
            .background(Color.App.surface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.large))
            .padding(.horizontal, Spacing.md)
        }
    }

    private func methodRow(_ method: PaymentMethodType) -> some View {
        Button {
            paymentEngine.selectedMethod = method
        } label: {
            HStack(spacing: Spacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: Radius.small)
                        .fill(isSelected(method) ? Color.App.primaryLight.opacity(0.15) : Color.App.background)
                        .frame(width: 40, height: 40)
                    Image(systemName: method.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(isSelected(method) ? Color.App.primary : Color.App.textSecondary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(method.rawValue)
                        .font(Font.App.bodyMedium)
                        .foregroundStyle(Color.App.textPrimary)
                    Text(method.subtitle)
                        .font(Font.App.caption)
                        .foregroundStyle(Color.App.textTertiary)
                }
                Spacer()
                Image(systemName: isSelected(method) ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected(method) ? Color.App.primary : Color.App.border)
                    .font(.system(size: 20))
            }
            .padding(Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func isSelected(_ method: PaymentMethodType) -> Bool {
        paymentEngine.selectedMethod == method
    }

    // MARK: – Detail Section

    @ViewBuilder
    private var detailSection: some View {
        switch paymentEngine.selectedMethod {
        case .upi:
            upiSection
        case .creditCard, .debitCard:
            cardSection
        case .wallet:
            walletSection
        case .netBanking:
            netBankingSection
        }
    }

    private var upiSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionTitle("Enter UPI ID")
            FloatingLabelTextField(
                label: "UPI ID",
                isRequired: true,
                text: Binding(
                    get: { paymentEngine.upiId },
                    set: { paymentEngine.upiId = $0 }
                ),
                keyboardType: .emailAddress,
                error: !paymentEngine.upiId.isEmpty && !paymentEngine.upiId.contains("@")
                    ? "Enter a valid UPI ID (e.g. name@upi)"
                    : nil
            )
            .padding(.horizontal, Spacing.md)

            Text("e.g. mobile@paytm, name@okaxis")
                .font(Font.App.small)
                .foregroundStyle(Color.App.textTertiary)
                .padding(.horizontal, Spacing.md)
        }
    }

    private var cardSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionTitle(paymentEngine.selectedMethod == .creditCard ? "Credit Card Details" : "Debit Card Details")

            FloatingLabelTextField(
                label: "Card Number",
                isRequired: true,
                text: Binding(
                    get: { paymentEngine.cardNumber },
                    set: { paymentEngine.cardNumber = formatCardNumber($0) }
                ),
                keyboardType: .numberPad
            )
            .padding(.horizontal, Spacing.md)

            HStack(spacing: Spacing.sm) {
                FloatingLabelTextField(
                    label: "MM / YY",
                    isRequired: true,
                    text: Binding(
                        get: { paymentEngine.cardExpiry },
                        set: { paymentEngine.cardExpiry = formatExpiry($0) }
                    ),
                    keyboardType: .numberPad
                )

                FloatingLabelTextField(
                    label: "CVV",
                    isRequired: true,
                    text: Binding(
                        get: { paymentEngine.cardCVV },
                        set: { val in
                            if val.count <= 3 { paymentEngine.cardCVV = val.filter(\.isNumber) }
                        }
                    ),
                    keyboardType: .numberPad
                )
            }
            .padding(.horizontal, Spacing.md)
        }
    }

    private var walletSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionTitle("Select Wallet")
            VStack(spacing: 0) {
                ForEach(paymentEngine.walletOptions, id: \.self) { wallet in
                    optionRow(wallet, isSelected: paymentEngine.selectedWallet == wallet) {
                        paymentEngine.selectedWallet = wallet
                    }
                    if wallet != paymentEngine.walletOptions.last {
                        Divider().padding(.horizontal, Spacing.md)
                    }
                }
            }
            .background(Color.App.surface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.large))
            .padding(.horizontal, Spacing.md)
        }
    }

    private var netBankingSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            sectionTitle("Select Bank")
            VStack(spacing: 0) {
                ForEach(paymentEngine.bankOptions, id: \.self) { bank in
                    optionRow(bank, isSelected: paymentEngine.selectedBank == bank) {
                        paymentEngine.selectedBank = bank
                    }
                    if bank != paymentEngine.bankOptions.last {
                        Divider().padding(.horizontal, Spacing.md)
                    }
                }
            }
            .background(Color.App.surface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.large))
            .padding(.horizontal, Spacing.md)
        }
    }

    private func optionRow(_ title: String, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                Text(title)
                    .font(Font.App.body)
                    .foregroundStyle(Color.App.textPrimary)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.App.primary : Color.App.border)
                    .font(.system(size: 20))
            }
            .padding(Spacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(Font.App.headline)
            .foregroundStyle(Color.App.textPrimary)
            .padding(.horizontal, Spacing.md)
    }

    // MARK: – Pay Button

    private var payButton: some View {
        VStack(spacing: 0) {
            Divider()
            PrimaryButton(
                title: "Pay ₹\(bookingEngine.fareBreakdown.total)",
                isLoading: false
            ) {
                coordinator.navigateToPaymentProcessing()
            }
            .disabled(!paymentEngine.isPaymentDetailValid)
            .padding(Spacing.md)
            .background(Color.App.background)
        }
    }

    // MARK: – Formatters

    private func formatCardNumber(_ raw: String) -> String {
        let digits = raw.filter(\.isNumber).prefix(16)
        var result = ""
        for (i, ch) in digits.enumerated() {
            if i > 0 && i % 4 == 0 { result += " " }
            result.append(ch)
        }
        return result
    }

    private func formatExpiry(_ raw: String) -> String {
        let digits = raw.filter(\.isNumber).prefix(4)
        if digits.count > 2 {
            let month = digits.prefix(2)
            let year  = digits.dropFirst(2)
            return "\(month) / \(year)"
        }
        return String(digits)
    }
}
