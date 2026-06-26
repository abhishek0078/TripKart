import Foundation

struct LocalResultsRepository: ResultsRepository {
    private let dataSource = LocalResultsDataSource()

    func fetchResults(for query: SearchQuery) async throws -> [TripResult] {
        try await Task.sleep(for: .milliseconds(700))
        return try await dataSource.fetchResults(for: query.pluginType)
    }
}
