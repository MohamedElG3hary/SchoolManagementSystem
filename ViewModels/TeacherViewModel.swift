import Foundation
import Combine

class TeacherViewModel: ObservableObject {
    @Published var teachers: [Teacher] = []
    private let db: DatabaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(db: DatabaseProtocol = InMemoryDatabaseManager.shared) {
        self.db = db
        loadTeachers()
        
        NotificationCenter.default.publisher(for: .databaseDidUpdate)
            .sink { [weak self] _ in
                self?.loadTeachers()
            }
            .store(in: &cancellables)
    }
    
    func loadTeachers() {
        teachers = db.getTeachers()
    }
    
    func addTeacher(name: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newTeacher = Teacher(id: UUID(), name: name)
        db.addTeacher(newTeacher)
    }
    
    func deleteTeacher(at offsets: IndexSet) {
        for index in offsets {
            db.deleteTeacher(id: teachers[index].id)
        }
    }
}
