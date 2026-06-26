import SwiftUI

struct SplashView: View {

    @Environment(SessionEngine.self) private var sessionEngine
    @Environment(AuthCoordinator.self) private var coordinator

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            Color.App.primary.ignoresSafeArea()

            VStack(spacing: Spacing.md) {
                Image(systemName: "airplane.departure")
                    .font(.system(size: 72, weight: .medium))
                    .foregroundStyle(.white)

                Text("TripKart")
                    .font(Font.App.display)
                    .foregroundStyle(.white)

                Text("Your Travel Companion")
                    .font(Font.App.body)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(duration: AnimationDuration.slow)) {
                scale = 1.0
                opacity = 1.0
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.8))
            await checkSession()
        }
    }

    private func checkSession() async {
        if sessionEngine.hasStoredSession {
            sessionEngine.restoreSession()
            // SessionEngine.isAuthenticated flips → AppRootView switches to HomeRootView
        } else {
            coordinator.navigateToLogin()
        }
    }
}

#Preview {
    NavigationStack {
        SplashView()
    }
    .environment(SessionEngine())
    .environment(AuthCoordinator())
}
