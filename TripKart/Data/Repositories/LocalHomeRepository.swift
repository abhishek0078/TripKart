import Foundation

final class LocalHomeRepository: HomeRepository {

    private let dataSource = LocalHomeDataSource()

    func fetchBanners() async throws -> [Banner] {
        try dataSource.fetchBanners()
    }

    func fetchCategories() async throws -> [TravelCategory] {
        try dataSource.fetchCategories()
    }

    func fetchOffers() async throws -> [Offer] {
        try dataSource.fetchOffers()
    }

    func fetchPopularDestinations() async throws -> [PopularDestination] {
        try dataSource.fetchPopularDestinations()
    }
}
