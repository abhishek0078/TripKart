import SwiftUI

enum BookingDestination: Hashable {
    case travellerForm
    case seatSelection(isReturn: Bool)
    case returnFlightSelection
    case reviewBooking
    case paymentPlaceholder
}

@Observable
final class BookingCoordinator {
    var path = NavigationPath()

    func navigateToTravellerForm()              { path.append(BookingDestination.travellerForm) }
    func navigateToOutboundSeats()              { path.append(BookingDestination.seatSelection(isReturn: false)) }
    func navigateToReturnFlightSelection()      { path.append(BookingDestination.returnFlightSelection) }
    func navigateToReturnSeats()                { path.append(BookingDestination.seatSelection(isReturn: true)) }
    func navigateToReviewBooking()              { path.append(BookingDestination.reviewBooking) }
    func navigateToPayment()                    { path.append(BookingDestination.paymentPlaceholder) }
    func popToRoot()                            { path = NavigationPath() }
}
