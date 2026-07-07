import Foundation

struct PairItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var brand: String
    var caseLocation: String
    var notes: String = ""
    var dateAdded: Date = Date()
    var isFavorite: Bool = false
}
