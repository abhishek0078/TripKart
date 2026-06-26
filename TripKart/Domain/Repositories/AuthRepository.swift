import Foundation

protocol AuthRepository {
    func sendOTP(to phoneNumber: String) async throws
    func verifyOTP(_ otp: String, for phoneNumber: String) async throws -> User
}
