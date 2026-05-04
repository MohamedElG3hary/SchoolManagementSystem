import Foundation
import Combine

class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []
    private let database: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(database: DatabaseServiceProtocol) {
        self.database = database
        loadStudents()
        
        NotificationCenter.default.publisher(for: .databaseDidUpdate)
            .sink { [weak self] _ in
                self?.loadStudents()
            }
            .store(in: &cancellables)
    }
    
    func loadStudents() {
        students = database.getStudents()
    }
    
    func addStudent(name: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newStudent = Student(id: UUID(), name: name)
        database.addStudent(newStudent)
    }
    
    func deleteStudent(at offsets: IndexSet) {
        for index in offsets {
            database.deleteStudent(id: students[index].id)
        }
    }
}
