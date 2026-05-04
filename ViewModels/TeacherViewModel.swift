import Foundation

class TeacherViewModel: ObservableObject {
    @Published var teachers: [Teacher] = []
    private let db: DatabaseProtocol
    
    init(db: DatabaseProtocol = SupabaseDatabaseManager.shared) {
        self.db = db
        loadTeachers()
    }
    
    func loadTeachers() {
        teachers = db.getTeachers()
    }
    
    func addTeacher(name: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newTeacher = Teacher(id: UUID(), name: name)
        db.addTeacher(newTeacher)
        loadTeachers()
    }
    func deleteTeacher(at offsets: IndexSet) {
        for index in offsets {
            db.deleteTeacher(id: teachers[index].id)
        }
        loadTeachers()
    }
}
