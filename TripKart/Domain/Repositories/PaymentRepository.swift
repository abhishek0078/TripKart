import Foundation

protocol PaymentRepository {
    func processPayment(method: PaymentMethodType, amount: Int) async throws -> PaymentResult
}
