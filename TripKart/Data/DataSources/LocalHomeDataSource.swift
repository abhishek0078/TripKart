import Foundation

struct LocalHomeDataSource {

    func fetchBanners() throws -> [Banner] {
        try load(resource: "banners", BannersResponse.self).banners
    }

    func fetchCategories() throws -> [TravelCategory] {
        try load(resource: "categories", CategoriesResponse.self).categories
    }

    func fetchOffers() throws -> [Offer] {
        try load(resource: "offers", OffersResponse.self).offers
    }

    func fetchPopularDestinations() throws -> [PopularDestination] {
        try load(resource: "popular_destinations", DestinationsResponse.self).destinations
    }

    private func load<T: Decodable>(resource: String, _ type: T.Type) throws -> T {
        guard let url = Bundle.main.url(forResource: resource, withExtension: "json") else {
            throw AppError.unknown("Missing resource: \(resource).json")
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
}

private struct BannersResponse: Decodable      { let banners: [Banner] }
private struct CategoriesResponse: Decodable   { let categories: [TravelCategory] }
private struct OffersResponse: Decodable        { let offers: [Offer] }
private struct DestinationsResponse: Decodable  { let destinations: [PopularDestination] }
