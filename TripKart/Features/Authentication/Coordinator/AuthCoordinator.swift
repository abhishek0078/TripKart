import SwiftUI
import Observation

enum AuthDestination: Hashable {
    case login
    case otp(phone: String)
}

@Observable
final class AuthCoordinator {

    var path = NavigationPath()

    func navigateToLogin() {
        path.append(AuthDestination.login)
    }

    func navigateToOTP(phone: String) {
        path.append(AuthDestination.otp(phone: phone))
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
