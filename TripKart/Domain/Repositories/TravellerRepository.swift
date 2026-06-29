import Foundation

protocol TravellerRepository {
    func fetchAll() async throws -> [Traveller]
    func save(_ traveller: Traveller) async throws
    func delete(id: String) async throws
}
