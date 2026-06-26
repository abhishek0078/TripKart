import Foundation
import Observation

@Observable
final class HomeViewModel {

    var banners: [Banner] = []
    var categories: [TravelCategory] = []
    var offers: [Offer] = []
    var popularDestinations: [PopularDestination] = []
    var state: ViewState = .idle

    private let homeRepository: any HomeRepository

    init(homeRepository: any HomeRepository) {
        self.homeRepository = homeRepository
    }

    @MainActor
    func loadHome() async {
        guard state != .loading else { return }
        state = .loading
        do {
            async let fetchedBanners      = homeRepository.fetchBanners()
            async let fetchedCategories   = homeRepository.fetchCategories()
            async let fetchedOffers       = homeRepository.fetchOffers()
            async let fetchedDestinations = homeRepository.fetchPopularDestinations()

            banners             = try await fetchedBanners
            categories          = try await fetchedCategories
            offers              = try await fetchedOffers
            popularDestinations = try await fetchedDestinations
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
