import SwiftUI

struct HomeRootView: View {

    @Environment(SessionEngine.self)       private var sessionEngine
    @Environment(HomeCoordinator.self)     private var coordinator
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: HomeViewModel
    @State private var selectedBooking: Booking?
    @State private var selectedOffer: Offer?
    @State private var unreadNotifCount = 0

    init(homeRepository: any HomeRepository, bookingRepository: any BookingRepository) {
        _viewModel = State(initialValue: HomeViewModel(
            homeRepository: homeRepository,
            bookingRepository: bookingRepository
        ))
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.xl) {
                greetingSection

                if !viewModel.upcomingBookings.isEmpty {
                    upcomingTripsSection
                }

                if !viewModel.banners.isEmpty {
                    BannerCarouselView(banners: viewModel.banners) { banner in
                        handleBannerTap(banner)
                    }
                    .padding(.horizontal, Spacing.lg)
                }

                if !viewModel.categories.isEmpty {
                    categorySection
                }

                if !viewModel.popularDestinations.isEmpty {
                    destinationsSection
                }

                if !viewModel.offers.isEmpty {
                    offersSection
                }
            }
            .padding(.bottom, Spacing.xxl)
        }
        .background(Color.App.background)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Text("TripKart")
                    .font(Font.App.headline)
                    .foregroundStyle(Color.App.primary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { coordinator.navigateToNotifications() } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: unreadNotifCount > 0 ? "bell.badge.fill" : "bell")
                            .font(.system(size: 18))
                            .foregroundStyle(unreadNotifCount > 0 ? Color.App.primary : Color.App.textPrimary)
                        if unreadNotifCount > 0 {
                            Text(unreadNotifCount > 9 ? "9+" : "\(unreadNotifCount)")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(3)
                                .background(Color.App.error)
                                .clipShape(Circle())
                                .offset(x: 7, y: -7)
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadHome()
            await loadUnreadCount()
        }
        .onAppear {
            Task {
                await viewModel.loadHome()
                await loadUnreadCount()
                consumePendingNavigation()
            }
        }
        .overlay {
            if viewModel.state == .loading && viewModel.banners.isEmpty {
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(Color.App.primary)
            }
        }
        .refreshable { await viewModel.loadHome() }
        .sheet(item: $selectedBooking) { booking in
            NavigationStack {
                BookingDetailView(booking: booking)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { selectedBooking = nil }
                        }
                    }
            }
        }
        .sheet(item: $selectedOffer) { offer in
            OfferFullDetailView(offer: offer) { travelType in
                selectedOffer = nil
                navigateForOffer(pluginType: travelType)
            }
        }
    }

    // MARK: – Notification count

    private func loadUnreadCount() async {
        unreadNotifCount = (try? await container.notificationEngine.repository.unreadCount()) ?? 0
    }

    // MARK: – Navigation helpers

    private func navigateForOffer(pluginType: String) {
        guard pluginType != "any" else { return }
        if let cat = viewModel.categories.first(where: { $0.pluginType == pluginType }) {
            coordinator.navigateToSearch(category: cat)
        }
    }

    // Called on appear — consumes a cross-tab navigation set from the Offers tab
    private func consumePendingNavigation() {
        guard let type = coordinator.pendingSearchPluginType else { return }
        coordinator.pendingSearchPluginType = nil
        navigateForOffer(pluginType: type)
    }

    // MARK: – Banner action

    private func handleBannerTap(_ banner: Banner) {
        switch banner.actionType {
        case "bus":
            if let cat = viewModel.categories.first(where: { $0.pluginType == "bus" }) {
                coordinator.navigateToSearch(category: cat)
            }
        case "flight":
            if let cat = viewModel.categories.first(where: { $0.pluginType == "flight" }) {
                coordinator.navigateToSearch(category: cat)
            }
        default:
            // Show offers as a sheet by picking the first offer
            if let first = viewModel.offers.first { selectedOffer = first }
        }
    }

    // MARK: – Sections

    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            let firstName = sessionEngine.currentUser?.name
                .components(separatedBy: " ").first ?? "Traveller"
            Text("Hello, \(firstName)! 👋")
                .font(Font.App.headline)
                .foregroundStyle(Color.App.textPrimary)
            Text("Where would you like to go today?")
                .font(Font.App.caption)
                .foregroundStyle(Color.App.textSecondary)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.top, Spacing.sm)
    }

    private var upcomingTripsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeaderView(title: "Upcoming Trips", showSeeAll: false)
                .padding(.horizontal, Spacing.lg)
            VStack(spacing: Spacing.sm) {
                ForEach(viewModel.upcomingBookings) { booking in
                    Button { selectedBooking = booking } label: {
                        UpcomingTripCardView(booking: booking)
                            .padding(.horizontal, Spacing.lg)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeaderView(title: "Travel Categories", showSeeAll: false)
                .padding(.horizontal, Spacing.lg)
            TravelCategoryGridView(categories: viewModel.categories) { category in
                coordinator.navigateToSearch(category: category)
            }
            .padding(.horizontal, Spacing.lg)
        }
    }

    private var destinationsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeaderView(title: "Popular Destinations")
                .padding(.horizontal, Spacing.lg)
            PopularDestinationsView(destinations: viewModel.popularDestinations)
        }
    }

    private var offersSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            SectionHeaderView(title: "Exclusive Offers")
                .padding(.horizontal, Spacing.lg)
            OffersCarouselView(offers: viewModel.offers) { offer in
                selectedOffer = offer
            }
        }
    }
}

