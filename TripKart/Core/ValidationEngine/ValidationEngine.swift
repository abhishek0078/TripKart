import Foundation

struct ValidationEngine {

    func validatePhone(_ phone: String) -> Result<Void, AppError> {
        let digits = phone.filter(\.isNumber)
        guard digits.count == 10 else {
            return .failure(.invalidPhone)
        }
        return .success(())
    }

    func validateOTP(_ otp: String) -> Result<Void, AppError> {
        guard otp.count == 6, otp.allSatisfy(\.isNumber) else {
            return .failure(.invalidOTP)
        }
        return .success(())
    }
}
