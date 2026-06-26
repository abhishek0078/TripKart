import SwiftUI

struct OTPVerificationView: View {

    @Environment(AuthCoordinator.self) private var coordinator
    @State private var viewModel: OTPVerificationViewModel

    init(
        phoneNumber: String,
        authRepository: any AuthRepository,
        validationEngine: ValidationEngine,
        sessionEngine: SessionEngine
    ) {
        _viewModel = State(initialValue: OTPVerificationViewModel(
            phoneNumber: phoneNumber,
            authRepository: authRepository,
            validationEngine: validationEngine,
            sessionEngine: sessionEngine
        ))
    }

    var body: some View {
        ZStack {
            Color.App.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    headerSection
                    otpSection
                    verifyButton
                    resendSection
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xl)
            }

            if viewModel.state == .loading {
                LoaderView(message: "Verifying OTP…")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startResendTimer()
        }
        .onChange(of: viewModel.otp) { _, _ in
            viewModel.clearError()
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color.App.primary)
                .padding(.top, Spacing.xxl)

            Text("Verify OTP")
                .font(Font.App.title)
                .foregroundStyle(Color.App.textPrimary)

            Group {
                Text("Enter the 6-digit code sent to\n")
                + Text(viewModel.maskedPhone).bold()
            }
            .font(Font.App.caption)
            .foregroundStyle(Color.App.textSecondary)
            .multilineTextAlignment(.center)
        }
    }

    private var otpSection: some View {
        VStack(spacing: Spacing.sm) {
            OTPField(otp: $viewModel.otp)

            if case .error(let msg) = viewModel.state {
                Text(msg)
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.error)
                    .multilineTextAlignment(.center)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: AnimationDuration.fast), value: viewModel.state)
    }

    private var verifyButton: some View {
        PrimaryButton(
            title: "Verify OTP",
            isLoading: viewModel.state == .loading,
            isDisabled: !viewModel.isOTPValid
        ) {
            Task { await viewModel.verifyOTP() }
        }
    }

    private var resendSection: some View {
        HStack(spacing: Spacing.xs) {
            Text("Didn't receive OTP?")
                .font(Font.App.caption)
                .foregroundStyle(Color.App.textSecondary)

            if viewModel.canResend {
                Button("Resend OTP") {
                    Task { await viewModel.resendOTP() }
                }
                .font(Font.App.captionMedium)
                .foregroundStyle(Color.App.primary)
            } else {
                Text("Resend in \(viewModel.resendCountdown)s")
                    .font(Font.App.captionMedium)
                    .foregroundStyle(Color.App.textTertiary)
            }
        }
    }
}

#Preview {
    let container = DependencyContainer()
    NavigationStack {
        OTPVerificationView(
            phoneNumber: "9876543210",
            authRepository: container.authRepository,
            validationEngine: container.validationEngine,
            sessionEngine: container.sessionEngine
        )
    }
    .environment(AuthCoordinator())
}
