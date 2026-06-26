import Foundation

struct LocationsResponse: Codable {
    let locations: [SearchLocation]
}

struct LocalLocationDataSource {
    func fetchLocations(from fileName: String) async throws -> [SearchLocation] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        let response = try JSONDecoder().decode(LocationsResponse.self, from: data)
        return response.locations
    }
}
