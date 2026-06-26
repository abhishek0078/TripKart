import SwiftUI

struct AuthFlowView: View {

    @Environment(DependencyContainer.self) private var container
    @State private var coordinator = AuthCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            SplashView()
                .navigationDestination(for: AuthDestination.self) { destination in
                    switch destination {
                    case .login:
                        LoginView(
                            authRepository: container.authRepository,
                            validationEngine: container.validationEngine
                        )

                    case .otp(let phone):
                        OTPVerificationView(
                            phoneNumber: phone,
                            authRepository: container.authRepository,
                            validationEngine: container.validationEngine,
                            sessionEngine: container.sessionEngine
                        )
                    }
                }
        }
        .environment(coordinator)
    }
}

#Preview {
    AuthFlowView()
        .environment(DependencyContainer())
        .environment(SessionEngine())
}
