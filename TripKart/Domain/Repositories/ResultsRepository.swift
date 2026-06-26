import Foundation

protocol ResultsRepository {
    func fetchResults(for query: SearchQuery) async throws -> [TripResult]
}
