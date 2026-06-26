import Foundation
import Observation

@Observable
final class OTPVerificationViewModel {

    var otp: String = ""
    var state: ViewState = .idle
    var resendCountdown: Int = 30
    var canResend: Bool = false

    let phoneNumber: String

    private let authRepository: any AuthRepository
    private let validationEngine: ValidationEngine
    private let sessionEngine: SessionEngine
    private var countdownTask: Task<Void, Never>?

    init(
        phoneNumber: String,
        authRepository: any AuthRepository,
        validationEngine: ValidationEngine,
        sessionEngine: SessionEngine
    ) {
        self.phoneNumber = phoneNumber
        self.authRepository = authRepository
        self.validationEngine = validationEngine
        self.sessionEngine = sessionEngine
    }

    var isOTPValid: Bool { otp.count == 6 }

    var maskedPhone: String {
        let digits = phoneNumber.filter(\.isNumber)
        guard digits.count >= 4 else { return phoneNumber }
        let prefix = String(digits.prefix(2))
        let suffix = String(digits.suffix(2))
        return "+91 \(prefix)XXXXXX\(suffix)"
    }

    @MainActor
    func verifyOTP() async {
        let result = validationEngine.validateOTP(otp)
        if case .failure(let error) = result {
            state = .error(error.localizedDescription)
            return
        }

        state = .loading
        do {
            let user = try await authRepository.verifyOTP(otp, for: phoneNumber.filter(\.isNumber))
            sessionEngine.login(user: user)
            state = .idle
        } catch let error as AppError {
            state = .error(error.localizedDescription)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    @MainActor
    func resendOTP() async {
        guard canResend else { return }
        state = .loading
        do {
            try await authRepository.sendOTP(to: phoneNumber.filter(\.isNumber))
            otp = ""
            state = .idle
            startResendTimer()
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func startResendTimer() {
        resendCountdown = 30
        canResend = false
        countdownTask?.cancel()
        countdownTask = Task { @MainActor in
            while resendCountdown > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                resendCountdown -= 1
            }
            if !Task.isCancelled {
                canResend = true
            }
        }
    }

    func clearError() {
        if case .error = state { state = .idle }
    }

    deinit {
        countdownTask?.cancel()
    }
}
