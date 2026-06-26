import SwiftUI

struct HomeRootView: View {

    @Environment(SessionEngine.self) private var sessionEngine
    @Environment(HomeCoordinator.self) private var coordinator
    @State private var viewModel: HomeViewModel

    init(homeRepository: any HomeRepository) {
        _viewModel = State(initialValue: HomeViewModel(homeRepository: homeRepository))
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: Spacing.xl) {
                greetingSection

                if !viewModel.banners.isEmpty {
                    BannerCarouselView(banners: viewModel.banners)
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
                Image(systemName: "bell")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.App.textPrimary)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadHome() }
        .overlay {
            if viewModel.state == .loading && viewModel.banners.isEmpty {
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(Color.App.primary)
            }
        }
        .refreshable { await viewModel.loadHome() }
    }

    // MARK: - Sections

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

            OffersCarouselView(offers: viewModel.offers)
        }
    }
}
