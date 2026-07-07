import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Jar] = []
    @Published var isPro: Bool = false

    /// Free-tier cap on number of items. Always kept comfortably above
    /// the seed-data count so a fresh install never hits the paywall.
    static let freeLimit = 3

    private let fileName = "cashjar_items.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
        if items.isEmpty {
            seedData()
            save()
        }
    }

    var isAtFreeLimit: Bool {
        !isPro && items.count >= Store.freeLimit
    }

    func add(_ item: Jar) -> Bool {
        guard isPro || items.count < Store.freeLimit else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: Jar) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Jar) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func seedData() {
        items = (0..<3).map { i in
            var item = Jar()
            item.createdAt = Date().addingTimeInterval(Double(-i) * 86400)
            return item
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([Jar].self, from: data) {
            items = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
