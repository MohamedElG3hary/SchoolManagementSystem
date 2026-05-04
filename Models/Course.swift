import Foundation

struct Course: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var teacherId: UUID?
    var enrolledStudentIds: [UUID]
}
