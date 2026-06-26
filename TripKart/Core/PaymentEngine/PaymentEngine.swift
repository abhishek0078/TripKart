import Foundation
import Observation

@Observable
final class PaymentEngine {
    var selectedMethod: PaymentMethodType = .upi
    var upiId: String = ""
    var cardNumber: String = ""
    var cardExpiry: String = ""
    var cardCVV: String = ""
    var selectedWallet: String = ""
    var selectedBank: String = ""
    var isProcessing = false

    let walletOptions = ["Paytm Wallet", "Amazon Pay", "MobiKwik", "PhonePe Wallet"]
    let bankOptions   = ["State Bank of India", "HDFC Bank", "ICICI Bank",
                         "Axis Bank", "Kotak Bank", "Punjab National Bank"]

    private let repository: any PaymentRepository

    init(repository: any PaymentRepository) {
        self.repository = repository
    }

    var isPaymentDetailValid: Bool {
        switch selectedMethod {
        case .upi:
            return upiId.contains("@") && upiId.count >= 5
        case .creditCard, .debitCard:
            let digits = cardNumber.filter(\.isNumber)
            return digits.count == 16 && cardExpiry.count >= 4 && cardCVV.count == 3
        case .wallet:
            return !selectedWallet.isEmpty
        case .netBanking:
            return !selectedBank.isEmpty
        }
    }

    func processPayment(amount: Int) async -> PaymentResult? {
        isProcessing = true
        defer { isProcessing = false }
        return try? await repository.processPayment(method: selectedMethod, amount: amount)
    }
}
