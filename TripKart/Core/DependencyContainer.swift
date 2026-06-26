import Foundation
import Observation

@Observable
final class DependencyContainer {

    let sessionEngine:        SessionEngine             = SessionEngine()
    let themeManager:         ThemeManager              = ThemeManager()
    let validationEngine:     ValidationEngine          = ValidationEngine()
    let pluginEngine:         PluginEngine              = PluginEngine()
    let authRepository:       any AuthRepository        = LocalAuthRepository()
    let homeRepository:       any HomeRepository        = LocalHomeRepository()
    let locationRepository:   any LocationRepository   = LocalLocationRepository()
    let resultsRepository:    any ResultsRepository    = LocalResultsRepository()
    let couponRepository:     any CouponRepository     = LocalCouponRepository()
    let bookingRepository:    any BookingRepository    = LocalBookingRepository()
}
