import Foundation

struct Jar: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var createdAt: Date = Date()
    var name: String
    var balance: Double

    init(id: UUID = UUID(), createdAt: Date = Date(), name: String = "", balance: Double = 0) {
        self.id = id
        self.createdAt = createdAt
        self.name = name
        self.balance = balance
    }
}
