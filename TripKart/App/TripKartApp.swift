import SwiftUI

@main
struct TripKartApp: App {

    @State private var container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(container.sessionEngine)
                .environment(container.themeManager)
                .environment(container)
        }
    }
}
