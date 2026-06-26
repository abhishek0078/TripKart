import Foundation

protocol LocationRepository {
    func fetchLocations(for pluginType: String) async throws -> [SearchLocation]
}
