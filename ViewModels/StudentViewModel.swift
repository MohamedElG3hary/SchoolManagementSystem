import Foundation

class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []
    private let db: DatabaseProtocol
    
    init(db: DatabaseProtocol = SupabaseDatabaseManager.shared) {
        self.db = db
        loadStudents()
    }
    
    func loadStudents() {
        students = db.getStudents()
    }
    
    func addStudent(name: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newStudent = Student(id: UUID(), name: name)
        db.addStudent(newStudent)
        loadStudents()
    }
    func deleteStudent(at offsets: IndexSet) {
        for index in offsets {
            db.deleteStudent(id: students[index].id)
        }
        loadStudents()
    }
}
