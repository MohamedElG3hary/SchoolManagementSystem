import Foundation
import Combine

class TeacherViewModel: ObservableObject {
    @Published var teachers: [Teacher] = []
    private let database: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(database: DatabaseServiceProtocol) {
        self.database = database
        loadTeachers()
        
        NotificationCenter.default.publisher(for: .databaseDidUpdate)
            .sink { [weak self] _ in
                self?.loadTeachers()
            }
            .store(in: &cancellables)
    }
    
    func loadTeachers() {
        teachers = database.getTeachers()
    }
    
    func addTeacher(name: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newTeacher = Teacher(id: UUID(), name: name)
        database.addTeacher(newTeacher)
    }
    
    func deleteTeacher(at offsets: IndexSet) {
        for index in offsets {
            database.deleteTeacher(id: teachers[index].id)
        }
    }
}
