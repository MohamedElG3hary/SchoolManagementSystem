import Foundation
import Combine

class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    private let db: DatabaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(db: DatabaseProtocol = InMemoryDatabaseManager.shared) {
        self.db = db
        loadCourses()
        
        NotificationCenter.default.publisher(for: .databaseDidUpdate)
            .sink { [weak self] _ in
                self?.loadCourses()
            }
            .store(in: &cancellables)
    }
    
    func loadCourses() {
        courses = db.getCourses()
    }
    
    func addCourse(title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newCourse = Course(id: UUID(), title: title, teacherId: nil, enrolledStudentIds: [])
        db.addCourse(newCourse)
    }
    
    func deleteCourse(at offsets: IndexSet) {
        for index in offsets {
            db.deleteCourse(id: courses[index].id)
        }
    }
    
    func assignTeacher(teacherId: UUID?, to courseId: UUID) {
        db.assignTeacherToCourse(teacherId: teacherId, courseId: courseId)
    }
    
    func enrollStudent(studentId: UUID, in courseId: UUID) {
        db.enrollStudentToCourse(studentId: studentId, courseId: courseId)
    }
    
    func unenrollStudent(studentId: UUID, from courseId: UUID) {
        db.unenrollStudentFromCourse(studentId: studentId, courseId: courseId)
    }
    
    // MARK: - Helpers for Views
    
    func getTeacher(for course: Course, from teachers: [Teacher]) -> Teacher? {
        guard let teacherId = course.teacherId else { return nil }
        return teachers.first(where: { $0.id == teacherId })
    }
    
    func getEnrolledStudents(for course: Course, from students: [Student]) -> [Student] {
        return students.filter { course.enrolledStudentIds.contains($0.id) }
    }
    
    func getCourses(for studentId: UUID) -> [Course] {
        return courses.filter { $0.enrolledStudentIds.contains(studentId) }
    }
    
    func getAvailableCourses(for studentId: UUID) -> [Course] {
        return courses.filter { !$0.enrolledStudentIds.contains(studentId) }
    }
    
    func getCourses(for teacherId: UUID) -> [Course] {
        return courses.filter { $0.teacherId == teacherId }
    }
}
