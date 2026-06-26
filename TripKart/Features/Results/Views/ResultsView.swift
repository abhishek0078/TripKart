import SwiftUI

struct ResultsView: View {
    @Environment(HomeCoordinator.self) private var coordinator
    @Environment(DependencyContainer.self) private var container
    @State private var viewModel: ResultsViewModel
    @State private var selectedTrip: TripResult?

    init(query: SearchQuery, plugin: any SearchPlugin, resultsRepository: any ResultsRepository) {
        _viewModel = State(initialValue: ResultsViewModel(
            query: query,
            plugin: plugin,
            resultsRepository: resultsRepository
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchSummaryView(query: viewModel.query) {
                coordinator.popToSearch()
            }

            filterSortBar

            Group {
                switch viewModel.viewState {
                case .loading:
                    loadingView
                case .empty:
                    emptyView
                case .error(let msg):
                    errorView(msg)
                default:
                    resultsList
                }
            }
        }
        .background(Color.App.background)
        .navigationTitle(
            "\(viewModel.query.origin.name) → \(viewModel.query.destination.name)"
        )
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadResults() }
        .sheet(isPresented: $viewModel.isSortSheetPresented) {
            SortSheet(selected: $viewModel.sortOption)
        }
        .sheet(isPresented: $viewModel.isFilterSheetPresented) {
            FilterSheet(
                filterOptions: $viewModel.filterOptions,
                allPriceRange: viewModel.allPriceRange,
                availableOperators: viewModel.availableOperators,
                showsStops: viewModel.plugin.pluginType == "flight"
            ) {
                viewModel.resetFilters()
            }
        }
        .onChange(of: viewModel.isSortSheetPresented) { _, isPresented in
            if !isPresented { viewModel.applyFiltersAndSort() }
        }
        .onChange(of: viewModel.isFilterSheetPresented) { _, isPresented in
            if !isPresented { viewModel.applyFiltersAndSort() }
        }
        .fullScreenCover(item: $selectedTrip) { trip in
            if let plugin = container.pluginEngine.plugin(for: trip.pluginType) {
                BookingFlowView(
                    tripResult: trip,
                    plugin: plugin,
                    query: viewModel.query,
                    couponRepository: container.couponRepository,
                    resultsRepository: container.resultsRepository,
                    bookingRepository: container.bookingRepository,
                    paymentRepository: container.paymentRepository
                )
            }
        }
    }

    private var filterSortBar: some View {
        HStack(spacing: Spacing.sm) {
            Button {
                viewModel.isSortSheetPresented = true
            } label: {
                Label(viewModel.sortOption.rawValue, systemImage: "arrow.up.arrow.down")
                    .font(Font.App.captionMedium)
                    .foregroundStyle(Color.App.primary)
                    .padding(.horizontal, Spacing.md)
                    .padding(.vertical, Spacing.xs)
                    .background(Color.App.primaryLight.opacity(0.12))
                    .clipShape(Capsule())
            }

            Button {
                viewModel.isFilterSheetPresented = true
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                    Text("Filters")
                    if viewModel.filterOptions.activeFilterCount > 0 {
                        Text("\(viewModel.filterOptions.activeFilterCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 16, height: 16)
                            .background(Color.App.primary)
                            .clipShape(Circle())
                    }
                }
                .font(Font.App.captionMedium)
                .foregroundStyle(
                    viewModel.filterOptions.activeFilterCount > 0 ? Color.App.primary : Color.App.textSecondary
                )
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.xs)
                .background(
                    viewModel.filterOptions.activeFilterCount > 0
                    ? Color.App.primaryLight.opacity(0.12)
                    : Color.App.surface
                )
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.App.border, lineWidth: 1))
            }

            Spacer()

            Text("\(viewModel.processedResults.count) results")
                .font(Font.App.caption)
                .foregroundStyle(Color.App.textTertiary)
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.sm)
        .background(Color.App.background)
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: Spacing.md) {
                ForEach(viewModel.displayedResults) { result in
                    Button {
                        selectedTrip = result
                    } label: {
                        TripCardView(result: result)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, Spacing.md)
                }

                if viewModel.hasMoreResults {
                    Button {
                        viewModel.loadNextPage()
                    } label: {
                        Text("Load More")
                            .font(Font.App.bodyMedium)
                            .foregroundStyle(Color.App.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Spacing.md)
                            .background(Color.App.surface)
                            .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
                            .overlay(
                                RoundedRectangle(cornerRadius: Radius.medium)
                                    .stroke(Color.App.border, lineWidth: 1)
                            )
                            .padding(.horizontal, Spacing.md)
                    }
                }
            }
            .padding(.vertical, Spacing.md)
        }
    }

    private var loadingView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.App.primary)
            Text("Searching best options...")
                .font(Font.App.body)
                .foregroundStyle(Color.App.textSecondary)
            Spacer()
        }
    }

    private var emptyView: some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 56))
                .foregroundStyle(Color.App.textTertiary)
            Text("No results found")
                .font(Font.App.title)
                .foregroundStyle(Color.App.textPrimary)
            Text("Try adjusting your filters or search criteria.")
                .font(Font.App.body)
                .foregroundStyle(Color.App.textSecondary)
                .multilineTextAlignment(.center)
            if !viewModel.filterOptions.isDefault {
                Button("Reset Filters") {
                    viewModel.resetFilters()
                }
                .font(Font.App.bodyMedium)
                .foregroundStyle(Color.App.primary)
            }
            Spacer()
        }
        .padding(.horizontal, Spacing.xl)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: Spacing.lg) {
            Spacer()
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 56))
                .foregroundStyle(Color.App.error.opacity(0.6))
            Text("Something went wrong")
                .font(Font.App.title)
                .foregroundStyle(Color.App.textPrimary)
            Text(message)
                .font(Font.App.body)
                .foregroundStyle(Color.App.textSecondary)
            Button("Retry") {
                Task { await viewModel.loadResults() }
            }
            .font(Font.App.bodyMedium)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.xl)
            .padding(.vertical, Spacing.sm)
            .background(Color.App.primary)
            .clipShape(Capsule())
            Spacer()
        }
        .padding(.horizontal, Spacing.xl)
    }
}
