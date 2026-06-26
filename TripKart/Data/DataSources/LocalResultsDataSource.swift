import Foundation

struct ResultsResponse: Codable {
    let results: [TripResult]
}

struct LocalResultsDataSource {
    func fetchResults(for pluginType: String) async throws -> [TripResult] {
        let fileName = pluginType == "flight" ? "flight_routes" : "bus_routes"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        let response = try JSONDecoder().decode(ResultsResponse.self, from: data)
        return response.results
    }
}
