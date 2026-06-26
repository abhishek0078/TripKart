import Foundation

final class LocalPaymentRepository: PaymentRepository {

    func processPayment(method: PaymentMethodType, amount: Int) async throws -> PaymentResult {
        try await Task.sleep(nanoseconds: 1_800_000_000)
        let isSuccess = Int.random(in: 1...100) <= 85
        let txnId = "TXN\(Int.random(in: 100_000...999_999))"

        return PaymentResult(
            transactionId: txnId,
            status: isSuccess ? .success : .failure,
            method: method,
            amount: amount,
            failureReason: isSuccess
                ? nil
                : "Payment declined by the bank. Please try a different method."
        )
    }
}
