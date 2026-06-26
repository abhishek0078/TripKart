import Foundation
import Observation

@Observable
final class SessionEngine {

    private(set) var currentUser: User?
    private(set) var isAuthenticated: Bool = false

    private let sessionKey = "tripkart.session.user"

    var hasStoredSession: Bool {
        UserDefaults.standard.data(forKey: sessionKey) != nil
    }

    func login(user: User) {
        currentUser = user
        isAuthenticated = true
        persist(user)
    }

    func logout() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: sessionKey)
    }

    func restoreSession() {
        guard
            let data = UserDefaults.standard.data(forKey: sessionKey),
            let user = try? JSONDecoder().decode(User.self, from: data)
        else { return }
        currentUser = user
        isAuthenticated = true
    }

    private func persist(_ user: User) {
        guard let data = try? JSONEncoder().encode(user) else { return }
        UserDefaults.standard.set(data, forKey: sessionKey)
    }
}
