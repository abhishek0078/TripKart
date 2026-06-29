import Foundation

final class LocalTravellerRepository: TravellerRepository {

    private let key = "tripkart.travellers"

    func fetchAll() async throws -> [Traveller] {
        if let data = UserDefaults.standard.data(forKey: key),
           let stored = try? JSONDecoder().decode([Traveller].self, from: data) {
            return stored
        }
        let seed = loadSeed()
        saveToDefaults(seed)
        return seed
    }

    func save(_ traveller: Traveller) async throws {
        var all = (try? await fetchAll()) ?? []
        if let idx = all.firstIndex(where: { $0.id == traveller.id }) {
            all[idx] = traveller
        } else {
            all.append(traveller)
        }
        saveToDefaults(all)
    }

    func delete(id: String) async throws {
        var all = (try? await fetchAll()) ?? []
        all.removeAll { $0.id == id }
        saveToDefaults(all)
    }

    private func saveToDefaults(_ travellers: [Traveller]) {
        guard let data = try? JSONEncoder().encode(travellers) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func loadSeed() -> [Traveller] {
        guard
            let url  = Bundle.main.url(forResource: "travellers", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let raw  = try? JSONDecoder().decode([String: [Traveller]].self, from: data),
            let list = raw["travellers"]
        else { return [] }
        return list
    }
}
