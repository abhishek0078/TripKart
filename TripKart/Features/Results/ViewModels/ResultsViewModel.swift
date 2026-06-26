import Foundation

@Observable
final class ResultsViewModel {
    let query: SearchQuery
    let plugin: any SearchPlugin

    private let resultsRepository: any ResultsRepository
    private let filterEngine = FilterEngine()
    private let sortEngine = SortEngine()

    private let pageSize = 10
    private var currentPage = 1

    var allResults: [TripResult] = []
    var processedResults: [TripResult] = []
    var displayedResults: [TripResult] = []

    var viewState: ViewState = .idle
    var sortOption: SortOption = .price
    var filterOptions = FilterOptions()

    var isFilterSheetPresented = false
    var isSortSheetPresented = false

    var hasMoreResults: Bool { displayedResults.count < processedResults.count }
    var availableOperators: [String] { filterEngine.availableOperators(from: allResults) }
    var allPriceRange: ClosedRange<Int> {
        let range = filterEngine.priceRange(from: allResults)
        return range.lowerBound...range.upperBound
    }

    init(query: SearchQuery, plugin: any SearchPlugin, resultsRepository: any ResultsRepository) {
        self.query = query
        self.plugin = plugin
        self.resultsRepository = resultsRepository
    }

    func loadResults() async {
        viewState = .loading
        do {
            allResults = try await resultsRepository.fetchResults(for: query)
            applyFiltersAndSort()
            viewState = allResults.isEmpty ? .empty : .loaded
        } catch {
            viewState = .error("Failed to load results.")
        }
    }

    func applyFiltersAndSort() {
        currentPage = 1
        let filtered = filterEngine.filter(allResults, with: filterOptions)
        processedResults = sortEngine.sort(filtered, by: sortOption)
        updateDisplayedResults()
    }

    func loadNextPage() {
        currentPage += 1
        updateDisplayedResults()
    }

    func resetFilters() {
        filterOptions = FilterOptions()
        applyFiltersAndSort()
    }

    private func updateDisplayedResults() {
        let end = min(currentPage * pageSize, processedResults.count)
        displayedResults = Array(processedResults.prefix(end))
    }
}
