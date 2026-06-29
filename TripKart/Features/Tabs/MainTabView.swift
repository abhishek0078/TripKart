import SwiftUI

struct MainTabView: View {

    @Environment(DependencyContainer.self) private var container
    @Environment(SessionEngine.self) private var sessionEngine
    @State private var homeCoordinator = HomeCoordinator()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack(path: $homeCoordinator.path) {
                HomeRootView(homeRepository: container.homeRepository, bookingRepository: container.bookingRepository)
                    .navigationDestination(for: HomeDestination.self) { destination in
                        switch destination {
                        case .search(let category):
                            if let plugin = container.pluginEngine.plugin(for: category.pluginType) {
                                SearchView(plugin: plugin, locationRepository: container.locationRepository)
                                    .toolbar(.hidden, for: .tabBar)
                            } else {
                                ComingSoonView(title: category.name, icon: category.systemIcon)
                                    .toolbar(.hidden, for: .tabBar)
                            }
                        case .offerDetail(let offer):
                            OfferDetailPlaceholder(offer: offer)
                                .toolbar(.hidden, for: .tabBar)
                        case .notifications:
                            NotificationsView()
                                .toolbar(.hidden, for: .tabBar)
                        case .results(let query):
                            if let plugin = container.pluginEngine.plugin(for: query.pluginType) {
                                ResultsView(query: query, plugin: plugin, resultsRepository: container.resultsRepository)
                                    .toolbar(.hidden, for: .tabBar)
                            }
                        }
                    }
            }
            .environment(homeCoordinator)
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(0)

            // Trips Tab
            NavigationStack {
                TripsView(bookingRepository: container.bookingRepository)
            }
            .tabItem { Label("Trips", systemImage: "ticket.fill") }
            .tag(1)

            // Offers Tab
            NavigationStack {
                OffersView(
                    homeRepository: container.homeRepository,
                    onStartBooking: { travelType in
                        homeCoordinator.pendingSearchPluginType = travelType
                        selectedTab = 0
                    }
                )
            }
            .tabItem { Label("Offers", systemImage: "tag.fill") }
            .tag(2)

            // Profile Tab
            NavigationStack {
                ProfileView()
            }
            .environment(sessionEngine)
            .tabItem { Label("Profile", systemImage: "person.fill") }
            .tag(3)
        }
        .tint(Color.App.primary)
    }
}

// MARK: - Placeholder screens

private struct ComingSoonView: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(Color.App.primary.opacity(0.4))
            Text(title)
                .font(Font.App.title)
                .foregroundStyle(Color.App.textPrimary)
            Text("Coming in the next phase.")
                .font(Font.App.caption)
                .foregroundStyle(Color.App.textSecondary)
            Spacer()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct OfferDetailPlaceholder: View {
    let offer: Offer
    var body: some View {
        VStack(spacing: Spacing.lg) {
            OfferCardView(offer: offer)
            Text("Full offer detail coming soon.")
                .font(Font.App.caption)
                .foregroundStyle(Color.App.textSecondary)
        }
        .padding()
        .navigationTitle(offer.code)
        .navigationBarTitleDisplayMode(.inline)
    }
}
