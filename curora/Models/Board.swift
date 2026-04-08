import Foundation

struct Board: Identifiable, Codable, Hashable {
    var id: String
    var title: String
    var type: String
    var coverImageURL: String
    var placeCount: Int
    var createdAt: Date
}
