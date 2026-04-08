// MARK: — User
import Foundation

struct AppUser: Identifiable, Codable, Hashable {
    var id: String          // Firebase Auth UID
    var email: String
    var displayName: String
    var createdAt: Date
}
