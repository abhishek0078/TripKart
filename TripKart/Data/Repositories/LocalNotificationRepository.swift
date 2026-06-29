import Foundation

final class LocalNotificationRepository: NotificationRepository {
    private let key = "tripkart.notifications"
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    private func load() -> [InAppNotification] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? decoder.decode([InAppNotification].self, from: data) else { return [] }
        return items.sorted { $0.createdAt > $1.createdAt }
    }

    private func persist(_ items: [InAppNotification]) {
        if let data = try? encoder.encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func fetchAll() async throws -> [InAppNotification] { load() }

    func add(_ notification: InAppNotification) async throws {
        var items = load()
        // Avoid duplicates by id
        guard !items.contains(where: { $0.id == notification.id }) else { return }
        items.insert(notification, at: 0)
        persist(items)
    }

    func markAsRead(id: String) async throws {
        var items = load()
        if let i = items.firstIndex(where: { $0.id == id }) {
            items[i].isRead = true
        }
        persist(items)
    }

    func markAllAsRead() async throws {
        var items = load()
        for i in items.indices { items[i].isRead = true }
        persist(items)
    }

    func delete(id: String) async throws {
        persist(load().filter { $0.id != id })
    }

    func unreadCount() async throws -> Int {
        load().filter { !$0.isRead }.count
    }
}
