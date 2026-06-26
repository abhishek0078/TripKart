import Foundation

enum AppError: LocalizedError, Equatable {
    case invalidPhone
    case invalidOTP
    case userNotFound
    case otpExpired
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidPhone:
            return "Please enter a valid 10-digit mobile number."
        case .invalidOTP:
            return "Invalid OTP. Please try again."
        case .userNotFound:
            return "No account found with this number."
        case .otpExpired:
            return "OTP has expired. Please request a new one."
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown(let message):
            return message
        }
    }
}
