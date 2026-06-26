import Foundation

protocol BookingRepository {
    func save(booking: Booking) async throws
    func fetchAll() async throws -> [Booking]
}
