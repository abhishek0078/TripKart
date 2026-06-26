import Foundation

final class LocalAuthRepository: AuthRepository {

    private let dataSource = LocalAuthDataSource()

    func sendOTP(to phoneNumber: String) async throws {
        // Simulate network delay
        try await Task.sleep(for: .milliseconds(800))
    }

    func verifyOTP(_ otp: String, for phoneNumber: String) async throws -> User {
        try await Task.sleep(for: .milliseconds(800))

        guard otp == "123456" else {
            throw AppError.invalidOTP
        }

        if let existing = try await dataSource.fetchUser(phone: phoneNumber) {
            return existing
        }

        // Auto-register if no account found
        return User(
            id: UUID().uuidString,
            name: "TripKart User",
            phone: phoneNumber,
            email: nil,
            avatar: nil
        )
    }
}
