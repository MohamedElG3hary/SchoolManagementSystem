import Foundation
import Combine

class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []
    private let db: DatabaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(db: DatabaseProtocol = InMemoryDatabaseManager.shared) {
        self.db = db
        loadStudents()
        
        NotificationCenter.default.publisher(for: .databaseDidUpdate)
            .sink { [weak self] _ in
                self?.loadStudents()
            }
            .store(in: &cancellables)
    }
    
    func loadStudents() {
        students = db.getStudents()
    }
    
    func addStudent(name: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newStudent = Student(id: UUID(), name: name)
        db.addStudent(newStudent)
    }
    
    func deleteStudent(at offsets: IndexSet) {
        for index in offsets {
            db.deleteStudent(id: students[index].id)
        }
    }
}
