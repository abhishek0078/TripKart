import SwiftUI

@Observable
private final class ReturnFlightViewModel {
    var results: [TripResult] = []
    var viewState: ViewState = .idle
    private let repository: any ResultsRepository

    init(repository: any ResultsRepository) {
        self.repository = repository
    }

    func load(query: SearchQuery) async {
        viewState = .loading
        // Build reverse query: swap origin/destination, use returnDate
        let reverseQuery = SearchQuery(
            pluginType: query.pluginType,
            origin: query.destination,
            destination: query.origin,
            travelDate: query.returnDate ?? query.travelDate,
            returnDate: nil,
            passengers: query.passengers,
            tripType: .oneWay
        )
        do {
            results = try await repository.fetchResults(for: reverseQuery)
            viewState = results.isEmpty ? .empty : .loaded
        } catch {
            viewState = .error("Failed to load return flights.")
        }
    }
}

struct ReturnFlightView: View {
    let resultsRepository: any ResultsRepository

    @Environment(BookingCoordinator.self) private var coordinator
    @Environment(BookingEngine.self) private var bookingEngine
    @State private var viewModel: ReturnFlightViewModel

    init(resultsRepository: any ResultsRepository) {
        self.resultsRepository = resultsRepository
        _viewModel = State(initialValue: ReturnFlightViewModel(repository: resultsRepository))
    }

    var body: some View {
        VStack(spacing: 0) {
            returnSummaryBanner

            Group {
                switch viewModel.viewState {
                case .loading:
                    VStack(spacing: Spacing.lg) {
                        Spacer()
                        ProgressView().scaleEffect(1.5).tint(Color.App.primary)
                        Text("Finding return flights...")
                            .font(Font.App.body).foregroundStyle(Color.App.textSecondary)
                        Spacer()
                    }
                case .empty:
                    VStack(spacing: Spacing.lg) {
                        Spacer()
                        Image(systemName: "airplane.departure")
                            .font(.system(size: 56)).foregroundStyle(Color.App.textTertiary)
                        Text("No return flights found")
                            .font(Font.App.title).foregroundStyle(Color.App.textPrimary)
                        Spacer()
                    }
                case .error(let msg):
                    Text(msg).font(Font.App.body).foregroundStyle(Color.App.error).padding()
                default:
                    flightList
                }
            }
        }
        .background(Color.App.background)
        .navigationTitle("Select Return Flight")
        .navigationBarTitleDisplayMode(.large)
        .task { await viewModel.load(query: bookingEngine.query) }
    }

    private var returnSummaryBanner: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "arrow.left.circle.fill")
                .foregroundStyle(Color.App.warning)
            VStack(alignment: .leading, spacing: 2) {
                Text("Return Journey")
                    .font(Font.App.bodyMedium).foregroundStyle(Color.App.textPrimary)
                let returnDate = bookingEngine.query.returnDate ?? bookingEngine.query.travelDate
                Text("\(bookingEngine.query.destination.name) → \(bookingEngine.query.origin.name) · \(returnDate.formatted(.dateTime.day().month(.abbreviated)))")
                    .font(Font.App.caption).foregroundStyle(Color.App.textSecondary)
            }
            Spacer()
        }
        .padding(Spacing.md)
        .background(Color.App.warning.opacity(0.08))
    }

    private var flightList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(viewModel.results) { result in
                    Button {
                        bookingEngine.returnResult = result
                        coordinator.navigateToReturnSeats()
                    } label: {
                        TripCardView(result: result)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Spacing.md)
                }
            }
            .padding(.vertical, Spacing.md)
        }
    }
}
