import Foundation

class InMemoryDatabaseManager: DatabaseServiceProtocol {
    private var students: [Student] = []
    private var teachers: [Teacher] = []
    private var courses: [Course] = []
    
    init() {
        setupMockData()
    }
    
    private func notifyUpdate() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .databaseDidUpdate, object: nil)
        }
    }
    
    private func setupMockData() {
        let student1 = Student(id: UUID(), name: "Alice Smith")
        let student2 = Student(id: UUID(), name: "Bob Johnson")
        students = [student1, student2]
        
        let teacher1 = Teacher(id: UUID(), name: "Mr. Davis")
        let teacher2 = Teacher(id: UUID(), name: "Mrs. Wilson")
        teachers = [teacher1, teacher2]
        
        let course1 = Course(id: UUID(), title: "Mathematics 101", teacherId: teacher1.id, enrolledStudentIds: [student1.id])
        let course2 = Course(id: UUID(), title: "History 201", teacherId: teacher2.id, enrolledStudentIds: [student1.id, student2.id])
        courses = [course1, course2]
    }
    
    func addStudent(_ student: Student) {
        students.append(student)
        notifyUpdate()
    }
    
    func getStudents() -> [Student] { return students }
    
    func updateStudent(_ student: Student) {
        if let index = students.firstIndex(where: { $0.id == student.id }) {
            students[index] = student
            notifyUpdate()
        }
    }
    
    func deleteStudent(id: UUID) {
        students.removeAll { $0.id == id }
        for i in 0..<courses.count {
            courses[i].enrolledStudentIds.removeAll { $0 == id }
        }
        notifyUpdate()
    }
    
    func addTeacher(_ teacher: Teacher) {
        teachers.append(teacher)
        notifyUpdate()
    }
    
    func getTeachers() -> [Teacher] { return teachers }
    
    func updateTeacher(_ teacher: Teacher) {
        if let index = teachers.firstIndex(where: { $0.id == teacher.id }) {
            teachers[index] = teacher
            notifyUpdate()
        }
    }
    
    func deleteTeacher(id: UUID) {
        teachers.removeAll { $0.id == id }
        for i in 0..<courses.count {
            if courses[i].teacherId == id {
                courses[i].teacherId = nil
            }
        }
        notifyUpdate()
    }
    
    func addCourse(_ course: Course) {
        courses.append(course)
        notifyUpdate()
    }
    
    func getCourses() -> [Course] { return courses }
    
    func updateCourse(_ course: Course) {
        if let index = courses.firstIndex(where: { $0.id == course.id }) {
            courses[index] = course
            notifyUpdate()
        }
    }
    
    func deleteCourse(id: UUID) {
        courses.removeAll { $0.id == id }
        notifyUpdate()
    }
    
    func assignTeacherToCourse(teacherId: UUID?, courseId: UUID) {
        if let index = courses.firstIndex(where: { $0.id == courseId }) {
            courses[index].teacherId = teacherId
            notifyUpdate()
        }
    }
    
    func enrollStudentToCourse(studentId: UUID, courseId: UUID) {
        if let index = courses.firstIndex(where: { $0.id == courseId }) {
            if !courses[index].enrolledStudentIds.contains(studentId) {
                courses[index].enrolledStudentIds.append(studentId)
                notifyUpdate()
            }
        }
    }
    
    func unenrollStudentFromCourse(studentId: UUID, courseId: UUID) {
        if let index = courses.firstIndex(where: { $0.id == courseId }) {
            courses[index].enrolledStudentIds.removeAll { $0 == studentId }
            notifyUpdate()
        }
    }
}
