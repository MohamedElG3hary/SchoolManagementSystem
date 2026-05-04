import Foundation
import Combine

class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    private let database: DatabaseServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(database: DatabaseServiceProtocol) {
        self.database = database
        loadCourses()
        
        NotificationCenter.default.publisher(for: .databaseDidUpdate)
            .sink { [weak self] _ in
                self?.loadCourses()
            }
            .store(in: &cancellables)
    }
    
    func loadCourses() {
        courses = database.getCourses()
    }
    
    func addCourse(title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newCourse = Course(id: UUID(), title: title, teacherId: nil, enrolledStudentIds: [])
        database.addCourse(newCourse)
    }
    
    func deleteCourse(at offsets: IndexSet) {
        for index in offsets {
            database.deleteCourse(id: courses[index].id)
        }
    }
    
    func assignTeacher(teacherId: UUID?, to courseId: UUID) {
        database.assignTeacherToCourse(teacherId: teacherId, courseId: courseId)
    }
    
    func enrollStudent(studentId: UUID, in courseId: UUID) {
        database.enrollStudentToCourse(studentId: studentId, courseId: courseId)
    }
    
    func unenrollStudent(studentId: UUID, from courseId: UUID) {
        database.unenrollStudentFromCourse(studentId: studentId, courseId: courseId)
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
