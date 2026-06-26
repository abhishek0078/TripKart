import SwiftUI

struct AppRootView: View {

    @Environment(SessionEngine.self) private var sessionEngine

    var body: some View {
        Group {
            if sessionEngine.isAuthenticated {
                MainTabView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
            } else {
                AuthFlowView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .trailing)
                    ))
            }
        }
        .animation(.easeInOut(duration: AnimationDuration.normal), value: sessionEngine.isAuthenticated)
    }
}

#Preview {
    AppRootView()
        .environment(SessionEngine())
        .environment(DependencyContainer())
}
