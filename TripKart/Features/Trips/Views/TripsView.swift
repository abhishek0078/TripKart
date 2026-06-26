import SwiftUI

private enum TripsTab: String, CaseIterable {
    case upcoming  = "Upcoming"
    case completed = "Completed"
}

@Observable
private final class TripsViewModel {
    var bookings: [Booking] = []
    var selectedTab: TripsTab = .upcoming
    var isLoading = false

    private let repository: any BookingRepository

    init(repository: any BookingRepository) {
        self.repository = repository
    }

    var filteredBookings: [Booking] {
        let today = Calendar.current.startOfDay(for: Date())
        switch selectedTab {
        case .upcoming:
            return bookings
                .filter { $0.travelDate >= today }
                .sorted { $0.travelDate < $1.travelDate }
        case .completed:
            return bookings
                .filter { $0.travelDate < today }
                .sorted { $0.travelDate > $1.travelDate }
        }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        bookings = (try? await repository.fetchAll()) ?? []
    }
}

struct TripsView: View {
    @State private var viewModel: TripsViewModel
    @State private var selectedBooking: Booking?

    init(bookingRepository: any BookingRepository) {
        _viewModel = State(initialValue: TripsViewModel(repository: bookingRepository))
    }

    var body: some View {
        VStack(spacing: 0) {
            tabPicker
            Divider()

            if viewModel.isLoading {
                loadingView
            } else if viewModel.filteredBookings.isEmpty {
                emptyView
            } else {
                bookingList
            }
        }
        .background(Color.App.background)
        .navigationTitle("My Trips")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: Booking.self) { booking in
            BookingDetailView(booking: booking)
        }
        .onAppear { Task { await viewModel.load() } }
        .refreshable { await viewModel.load() }
    }

    // MARK: – Tab Picker

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(TripsTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { viewModel.selectedTab = tab }
                } label: {
                    VStack(spacing: 6) {
                        Text(tab.rawValue)
                            .font(viewModel.selectedTab == tab ? Font.App.bodyMedium : Font.App.body)
                            .foregroundStyle(
                                viewModel.selectedTab == tab ? Color.App.primary : Color.App.textSecondary
                            )
                        Rectangle()
                            .fill(viewModel.selectedTab == tab ? Color.App.primary : Color.clear)
                            .frame(height: 2)
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.sm)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, Spacing.md)
        .background(Color.App.background)
    }

    // MARK: – Booking List

    private var bookingList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(viewModel.filteredBookings) { booking in
                    NavigationLink(value: booking) {
                        BookingCardView(booking: booking)
                            .padding(.horizontal, Spacing.md)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, Spacing.md)
        }
    }

    // MARK: – Empty & Loading

    private var emptyView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: viewModel.selectedTab == .upcoming ? "ticket" : "clock.arrow.circlepath")
                .font(.system(size: 64))
                .foregroundStyle(Color.App.primary.opacity(0.3))
            Text(viewModel.selectedTab == .upcoming ? "No Upcoming Trips" : "No Past Trips")
                .font(Font.App.title)
                .foregroundStyle(Color.App.textPrimary)
            Text(viewModel.selectedTab == .upcoming
                 ? "Your confirmed bookings will appear here."
                 : "Completed journeys will appear here.")
                .font(Font.App.body)
                .foregroundStyle(Color.App.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)
            Spacer()
        }
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            ProgressView()
                .scaleEffect(1.4)
                .tint(Color.App.primary)
            Text("Loading trips…")
                .font(Font.App.body)
                .foregroundStyle(Color.App.textSecondary)
            Spacer()
        }
    }
}
