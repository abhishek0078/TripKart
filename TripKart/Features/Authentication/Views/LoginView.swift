import SwiftUI

struct LoginView: View {

    @Environment(AuthCoordinator.self) private var coordinator
    @State private var viewModel: LoginViewModel

    init(authRepository: any AuthRepository, validationEngine: ValidationEngine) {
        _viewModel = State(initialValue: LoginViewModel(
            authRepository: authRepository,
            validationEngine: validationEngine
        ))
    }

    var body: some View {
        ZStack {
            Color.App.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    headerSection
                    formSection
                    termsSection
                }
                .padding(.horizontal, Spacing.lg)
                .padding(.bottom, Spacing.xl)
            }

            if viewModel.state == .loading {
                LoaderView(message: "Sending OTP…")
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: viewModel.phoneNumber) { _, _ in
            viewModel.clearError()
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "airplane.departure")
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(Color.App.primary)
                .padding(.top, Spacing.xxl)

            Text("TripKart")
                .font(Font.App.display)
                .foregroundStyle(Color.App.primary)

            Text("Your Travel Companion")
                .font(Font.App.caption)
                .foregroundStyle(Color.App.textSecondary)
        }
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text("Enter Mobile Number")
                    .font(Font.App.headline)
                    .foregroundStyle(Color.App.textPrimary)

                Text("We'll send a 6-digit OTP to verify your number")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
            }

            AppTextField(
                placeholder: "10-digit mobile number",
                text: $viewModel.phoneNumber,
                keyboardType: .phonePad,
                errorMessage: errorMessage,
                prefix: "+91",
                maxLength: 10
            )

            PrimaryButton(
                title: "Get OTP",
                isLoading: viewModel.state == .loading,
                isDisabled: !viewModel.isPhoneValid
            ) {
                Task {
                    let sent = await viewModel.sendOTP()
                    if sent {
                        coordinator.navigateToOTP(phone: viewModel.phoneNumber)
                    }
                }
            }
        }
    }

    private var termsSection: some View {
        Text("By continuing, you agree to our **Terms of Service** and **Privacy Policy**")
            .font(Font.App.small)
            .foregroundStyle(Color.App.textTertiary)
            .multilineTextAlignment(.center)
    }

    private var errorMessage: String? {
        if case .error(let msg) = viewModel.state { return msg }
        return nil
    }
}

#Preview {
    NavigationStack {
        LoginView(
            authRepository: LocalAuthRepository(),
            validationEngine: ValidationEngine()
        )
    }
    .environment(AuthCoordinator())
}
