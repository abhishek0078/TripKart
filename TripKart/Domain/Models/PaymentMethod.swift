import Foundation

enum PaymentMethodType: String, Codable, CaseIterable, Hashable, Sendable {
    case upi         = "UPI"
    case creditCard  = "Credit Card"
    case debitCard   = "Debit Card"
    case wallet      = "Wallet"
    case netBanking  = "Net Banking"

    var icon: String {
        switch self {
        case .upi:        return "qrcode"
        case .creditCard: return "creditcard.fill"
        case .debitCard:  return "creditcard"
        case .wallet:     return "wallet.pass.fill"
        case .netBanking: return "building.columns.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .upi:        return "Google Pay, PhonePe, Paytm UPI"
        case .creditCard: return "Visa, Mastercard, Rupay"
        case .debitCard:  return "All major bank debit cards"
        case .wallet:     return "Paytm, Amazon Pay, MobiKwik"
        case .netBanking: return "SBI, HDFC, ICICI, Axis & more"
        }
    }
}
