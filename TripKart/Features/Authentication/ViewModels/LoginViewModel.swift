import Foundation
import Observation

@Observable
final class LoginViewModel {

    var phoneNumber: String = ""
    var state: ViewState = .idle

    private let authRepository: any AuthRepository
    private let validationEngine: ValidationEngine

    init(authRepository: any AuthRepository, validationEngine: ValidationEngine) {
        self.authRepository = authRepository
        self.validationEngine = validationEngine
    }

    var isPhoneValid: Bool {
        phoneNumber.filter(\.isNumber).count == 10
    }

    @MainActor
    func sendOTP() async -> Bool {
        let result = validationEngine.validatePhone(phoneNumber)
        if case .failure(let error) = result {
            state = .error(error.localizedDescription)
            return false
        }

        state = .loading
        do {
            try await authRepository.sendOTP(to: phoneNumber.filter(\.isNumber))
            state = .idle
            return true
        } catch let error as AppError {
            state = .error(error.localizedDescription)
            return false
        } catch {
            state = .error(error.localizedDescription)
            return false
        }
    }

    func clearError() {
        if case .error = state { state = .idle }
    }
}
