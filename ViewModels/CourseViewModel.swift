import Foundation

class CourseViewModel: ObservableObject {
    @Published var courses: [Course] = []
    private let db: DatabaseProtocol
    
    init(db: DatabaseProtocol = SupabaseDatabaseManager.shared) {
        self.db = db
        loadCourses()
    }
    
    func loadCourses() {
        courses = db.getCourses()
    }
    
    func addCourse(title: String) {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newCourse = Course(id: UUID(), title: title, teacherId: nil, enrolledStudentIds: [])
        db.addCourse(newCourse)
        loadCourses()
    }
    
    func assignTeacher(teacherId: UUID?, to courseId: UUID) {
        db.assignTeacherToCourse(teacherId: teacherId, courseId: courseId)
        loadCourses()
    }
    
    func enrollStudent(studentId: UUID, in courseId: UUID) {
        db.enrollStudentToCourse(studentId: studentId, courseId: courseId)
        loadCourses()
    }
    
    func unenrollStudent(studentId: UUID, from courseId: UUID) {
        db.unenrollStudentFromCourse(studentId: studentId, courseId: courseId)
        loadCourses()
    }
    
    func deleteCourse(at offsets: IndexSet) {
        for index in offsets {
            db.deleteCourse(id: courses[index].id)
        }
        loadCourses()
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
