import SwiftUI

struct NotificationsView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var notifications: [InAppNotification] = []
    @State private var isLoading = false
    @State private var selectedBookingId: String?
    @State private var selectedBooking: Booking?

    private var unread: [InAppNotification] { notifications.filter { !$0.isRead } }
    private var today: [InAppNotification] {
        notifications.filter { Calendar.current.isDateInToday($0.createdAt) }
    }
    private var earlier: [InAppNotification] {
        notifications.filter { !Calendar.current.isDateInToday($0.createdAt) }
    }

    var body: some View {
        Group {
            if isLoading && notifications.isEmpty {
                ProgressView().tint(Color.App.primary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if notifications.isEmpty {
                emptyState
            } else {
                list
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .background(Color.App.background)
        .toolbar {
            if !unread.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Mark all read") {
                        Task { await markAllRead() }
                    }
                    .font(Font.App.captionMedium)
                }
            }
        }
        .task { await load() }
        .sheet(item: $selectedBooking) { booking in
            NavigationStack {
                BookingDetailView(booking: booking)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") { selectedBooking = nil }
                        }
                    }
            }
        }
    }

    // MARK: – List

    private var list: some View {
        List {
            if !today.isEmpty {
                Section("Today") {
                    ForEach(today) { notif in
                        NotificationRow(notification: notif)
                            .contentShape(Rectangle())
                            .onTapGesture { handleTap(notif) }
                    }
                    .onDelete { offsets in deleteFromToday(offsets) }
                }
            }
            if !earlier.isEmpty {
                Section("Earlier") {
                    ForEach(earlier) { notif in
                        NotificationRow(notification: notif)
                            .contentShape(Rectangle())
                            .onTapGesture { handleTap(notif) }
                    }
                    .onDelete { offsets in deleteFromEarlier(offsets) }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: – Empty

    private var emptyState: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundStyle(Color.App.primary.opacity(0.35))
            VStack(spacing: Spacing.xs) {
                Text("No Notifications")
                    .font(Font.App.title)
                    .foregroundStyle(Color.App.textPrimary)
                Text("Booking confirmations and trip\nreminders will appear here.")
                    .font(Font.App.caption)
                    .foregroundStyle(Color.App.textSecondary)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
    }

    // MARK: – Actions

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        notifications = (try? await container.notificationEngine.repository.fetchAll()) ?? []
    }

    private func handleTap(_ notif: InAppNotification) {
        Task {
            try? await container.notificationEngine.repository.markAsRead(id: notif.id)
            await load()
            if let bookingId = notif.bookingId {
                let all = (try? await container.bookingRepository.fetchAll()) ?? []
                selectedBooking = all.first(where: { $0.id == bookingId })
            }
        }
    }

    private func markAllRead() async {
        try? await container.notificationEngine.repository.markAllAsRead()
        await load()
    }

    private func deleteFromToday(_ offsets: IndexSet) {
        let items = offsets.map { today[$0] }
        Task {
            for n in items { try? await container.notificationEngine.repository.delete(id: n.id) }
            await load()
        }
    }

    private func deleteFromEarlier(_ offsets: IndexSet) {
        let items = offsets.map { earlier[$0] }
        Task {
            for n in items { try? await container.notificationEngine.repository.delete(id: n.id) }
            await load()
        }
    }
}

// MARK: – Row

private struct NotificationRow: View {
    let notification: InAppNotification

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: notification.type.colorHex).opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: notification.type.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(Color(hex: notification.type.colorHex))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(notification.title)
                    .font(notification.isRead ? Font.App.body : Font.App.bodyMedium)
                    .foregroundStyle(Color.App.textPrimary)
                    .lineLimit(1)
                Text(notification.body)
                    .font(Font.App.small)
                    .foregroundStyle(Color.App.textSecondary)
                    .lineLimit(2)
                Text(timeAgo(notification.createdAt))
                    .font(Font.App.small)
                    .foregroundStyle(Color.App.textTertiary)
            }

            Spacer()

            if !notification.isRead {
                Circle()
                    .fill(Color.App.primary)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, Spacing.xs)
        .listRowBackground(
            notification.isRead ? Color.clear : Color.App.primary.opacity(0.03)
        )
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = -date.timeIntervalSinceNow
        if seconds < 60  { return "Just now" }
        if seconds < 3600  { return "\(Int(seconds / 60))m ago" }
        if seconds < 86400 { return "\(Int(seconds / 3600))h ago" }
        if seconds < 604800 { return "\(Int(seconds / 86400))d ago" }
        let f = DateFormatter(); f.dateFormat = "d MMM"
        return f.string(from: date)
    }
}
