import Foundation
import Observation

@Observable
final class HomeViewModel {

    var banners: [Banner] = []
    var categories: [TravelCategory] = []
    var offers: [Offer] = []
    var popularDestinations: [PopularDestination] = []
    var upcomingBookings: [Booking] = []
    var state: ViewState = .idle

    private let homeRepository:    any HomeRepository
    private let bookingRepository: any BookingRepository

    init(homeRepository: any HomeRepository, bookingRepository: any BookingRepository) {
        self.homeRepository    = homeRepository
        self.bookingRepository = bookingRepository
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
            async let fetchedBookings     = bookingRepository.fetchAll()

            banners             = try await fetchedBanners
            categories          = try await fetchedCategories
            offers              = try await fetchedOffers
            popularDestinations = try await fetchedDestinations

            let today = Calendar.current.startOfDay(for: Date())
            upcomingBookings = (try? await fetchedBookings)?
                .filter { $0.travelDate >= today }
                .sorted { $0.travelDate < $1.travelDate }
                .prefix(3)
                .map { $0 }
                ?? []

            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
