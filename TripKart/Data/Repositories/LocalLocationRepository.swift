import Foundation

struct LocalLocationRepository: LocationRepository {
    private let dataSource = LocalLocationDataSource()

    func fetchLocations(for pluginType: String) async throws -> [SearchLocation] {
        let fileName = pluginType == "flight" ? "airports" : "cities"
        return try await dataSource.fetchLocations(from: fileName)
    }
}
