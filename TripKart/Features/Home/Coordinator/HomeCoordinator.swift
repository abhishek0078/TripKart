import SwiftUI
import Observation

enum HomeDestination: Hashable {
    case search(category: TravelCategory)
    case offerDetail(offer: Offer)
    case results(query: SearchQuery)
}

@Observable
final class HomeCoordinator {
    var path = NavigationPath()

    func navigateToSearch(category: TravelCategory) {
        path.append(HomeDestination.search(category: category))
    }

    func navigateToOfferDetail(offer: Offer) {
        path.append(HomeDestination.offerDetail(offer: offer))
    }

    func navigateToResults(query: SearchQuery) {
        path.append(HomeDestination.results(query: query))
    }

    func popToSearch() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
}
