import Foundation

@Observable
final class SearchViewModel {
    private let plugin: any SearchPlugin
    private let locationRepository: any LocationRepository
    private let searchEngine: SearchEngine

    var locations: [SearchLocation] = []
    var origin: SearchLocation?
    var destination: SearchLocation?
    var travelDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    var returnDate: Date = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    var passengers: Int = 1
    var tripType: TripType = .oneWay

    var viewState: ViewState = .idle
    var errorMessage: String?
    var isLocationPickerPresented: Bool = false
    var isPickingOrigin: Bool = true
    var isTravelDatePickerPresented: Bool = false
    var isReturnDatePickerPresented: Bool = false
    var isPassengerPickerPresented: Bool = false
    var locationSearchText: String = ""

    var filteredLocations: [SearchLocation] {
        guard !locationSearchText.isEmpty else { return locations }
        let q = locationSearchText.lowercased()
        return locations.filter {
            $0.name.lowercased().contains(q) ||
            $0.subtitle.lowercased().contains(q) ||
            $0.code.lowercased().contains(q)
        }
    }

    init(plugin: any SearchPlugin, locationRepository: any LocationRepository) {
        self.plugin = plugin
        self.locationRepository = locationRepository
        self.searchEngine = SearchEngine()
    }

    var currentPlugin: any SearchPlugin { plugin }

    func loadLocations() async {
        viewState = .loading
        do {
            locations = try await locationRepository.fetchLocations(for: plugin.pluginType)
            viewState = .loaded
        } catch {
            viewState = .error("Failed to load locations.")
        }
    }

    func selectLocation(_ location: SearchLocation) {
        if isPickingOrigin {
            origin = location
        } else {
            destination = location
        }
        isLocationPickerPresented = false
        locationSearchText = ""
    }

    func swapLocations() {
        let temp = origin
        origin = destination
        destination = temp
    }

    func buildQuery() -> SearchQuery? {
        guard let origin, let destination else { return nil }
        return SearchQuery(
            pluginType: plugin.pluginType,
            origin: origin,
            destination: destination,
            travelDate: travelDate,
            returnDate: plugin.supportsTripType && tripType == .roundTrip ? returnDate : nil,
            passengers: passengers,
            tripType: tripType
        )
    }

    func validateAndSearch() -> Result<SearchQuery, AppError> {
        guard let query = buildQuery() else {
            return .failure(.unknown("Please select origin and destination."))
        }
        let result = searchEngine.validate(query: query, plugin: plugin)
        switch result {
        case .success:
            return .success(query)
        case .failure(let error):
            return .failure(error)
        }
    }
}
