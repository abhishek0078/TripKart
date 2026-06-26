import Foundation

final class LocalBookingRepository: BookingRepository {
    private var bookings: [Booking] = []

    func save(booking: Booking) async throws {
        bookings.removeAll { $0.id == booking.id }
        bookings.append(booking)
    }

    func fetchAll() async throws -> [Booking] {
        bookings
    }
}
