import Foundation

struct Student: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
}
