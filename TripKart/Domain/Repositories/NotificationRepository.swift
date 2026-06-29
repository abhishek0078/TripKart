import Foundation

protocol NotificationRepository {
    func fetchAll() async throws -> [InAppNotification]
    func add(_ notification: InAppNotification) async throws
    func markAsRead(id: String) async throws
    func markAllAsRead() async throws
    func delete(id: String) async throws
    func unreadCount() async throws -> Int
}
