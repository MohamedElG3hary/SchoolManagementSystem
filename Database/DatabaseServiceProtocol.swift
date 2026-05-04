import Foundation

extension Notification.Name {
    static let databaseDidUpdate = Notification.Name("databaseDidUpdate")
}

protocol DatabaseProtocol {
    func addStudent(_ student: Student)
    func getStudents() -> [Student]
    func updateStudent(_ student: Student)
    func deleteStudent(id: UUID)
    
    func addTeacher(_ teacher: Teacher)
    func getTeachers() -> [Teacher]
    func updateTeacher(_ teacher: Teacher)
    func deleteTeacher(id: UUID)
    
    func addCourse(_ course: Course)
    func getCourses() -> [Course]
    func updateCourse(_ course: Course)
    func deleteCourse(id: UUID)
    
    func assignTeacherToCourse(teacherId: UUID?, courseId: UUID)
    func enrollStudentToCourse(studentId: UUID, courseId: UUID)
    func unenrollStudentFromCourse(studentId: UUID, courseId: UUID)
}
