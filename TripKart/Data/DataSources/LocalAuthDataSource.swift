import Foundation

struct LocalAuthDataSource {
    func fetchUser(phone: String) async throws -> User? {
        guard let url = Bundle.main.url(forResource: "users", withExtension: "json") else {
            return nil
        }
        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(UsersResponse.self, from: data)
        return response.users.first { $0.phone == phone }
    }
}

private struct UsersResponse: Decodable {
    let users: [User]
}
