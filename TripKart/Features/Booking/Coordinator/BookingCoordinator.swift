import SwiftUI

enum BookingDestination: Hashable {
    case travellerForm
    case seatSelection(isReturn: Bool)
    case returnFlightSelection
    case reviewBooking
    case payment
    case paymentProcessing
    case paymentSuccess(booking: Booking)
    case paymentFailure(reason: String)
}

@Observable
final class BookingCoordinator {
    var path = NavigationPath()
    var onDismiss: (() -> Void)?

    func navigateToTravellerForm()                          { path.append(BookingDestination.travellerForm) }
    func navigateToOutboundSeats()                          { path.append(BookingDestination.seatSelection(isReturn: false)) }
    func navigateToReturnFlightSelection()                  { path.append(BookingDestination.returnFlightSelection) }
    func navigateToReturnSeats()                            { path.append(BookingDestination.seatSelection(isReturn: true)) }
    func navigateToReviewBooking()                          { path.append(BookingDestination.reviewBooking) }
    func navigateToPayment()                                { path.append(BookingDestination.payment) }
    func navigateToPaymentProcessing()                      { path.append(BookingDestination.paymentProcessing) }
    func navigateToPaymentSuccess(booking: Booking)         { path.append(BookingDestination.paymentSuccess(booking: booking)) }
    func navigateToPaymentFailure(reason: String)           { path.append(BookingDestination.paymentFailure(reason: reason)) }

    func retryPayment() {
        if path.count >= 2 { path.removeLast(2) }
        else if !path.isEmpty { path.removeLast() }
    }

    func popToRoot()    { path = NavigationPath() }
    func dismiss()      { onDismiss?() }
}
