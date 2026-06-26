import Foundation

protocol HomeRepository {
    func fetchBanners() async throws -> [Banner]
    func fetchCategories() async throws -> [TravelCategory]
    func fetchOffers() async throws -> [Offer]
    func fetchPopularDestinations() async throws -> [PopularDestination]
}
