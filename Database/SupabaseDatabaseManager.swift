import Foundation
import Supabase

class SupabaseDatabaseManager: DatabaseProtocol {
    static let shared = SupabaseDatabaseManager()
    
    // Initialize Supabase Client
    let client = SupabaseClient(
        supabaseURL: URL(string: "https://ouvvfeqcewklyoidtiyc.supabase.co")!,
6       supabaseKey: "sb_publishable_wf31RmrCEpIe-IfF5Tw9PQ_MSepW37s"
    )
    
    // Local cache for synchronous protocol conformance
    private var students: [Student] = []
    private var teachers: [Teacher] = []
    private var courses: [Course] = []
    
    private init() {
        Task {
            await fetchAll()
        }
    }
    
    private func notifyUpdate() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .databaseDidUpdate, object: nil)
        }
    }
    
    // MARK: - Initial Fetch
    
    private func fetchAll() async {
        do {
            let fetchedStudents: [Student] = try await client.from("students").select().execute().value
            let fetchedTeachers: [Teacher] = try await client.from("teachers").select().execute().value
            let fetchedCourses: [Course] = try await client.from("courses").select().execute().value
            
            DispatchQueue.main.async {
                self.students = fetchedStudents
                self.teachers = fetchedTeachers
                self.courses = fetchedCourses
                self.notifyUpdate()
            }
        } catch {
            print("Error fetching data from Supabase: \(error)")
        }
    }
    
    // MARK: - Students
    
    func addStudent(_ student: Student) {
        students.append(student)
        notifyUpdate()
        
        Task {
            do {
                try await client.from("students").insert(student).execute()
            } catch {
                print("Failed to add student: \(error)")
            }
        }
    }
    
    func getStudents() -> [Student] { return students }
    
    func updateStudent(_ student: Student) {
        if let index = students.firstIndex(where: { $0.id == student.id }) {
            students[index] = student
            notifyUpdate()
        }
        
        Task {
            do {
                try await client.from("students").update(student).eq("id", value: student.id.uuidString).execute()
            } catch {
                print("Failed to update student: \(error)")
            }
        }
    }
    
    func deleteStudent(id: UUID) {
        students.removeAll { $0.id == id }
        for i in 0..<courses.count {
            courses[i].enrolledStudentIds.removeAll { $0 == id }
        }
        notifyUpdate()
        
        Task {
            do {
                try await client.from("students").delete().eq("id", value: id.uuidString).execute()
            } catch {
                print("Failed to delete student: \(error)")
            }
        }
    }
    
    // MARK: - Teachers
    
    func addTeacher(_ teacher: Teacher) {
        teachers.append(teacher)
        notifyUpdate()
        
        Task {
            do {
                try await client.from("teachers").insert(teacher).execute()
            } catch {
                print("Failed to add teacher: \(error)")
            }
        }
    }
    
    func getTeachers() -> [Teacher] { return teachers }
    
    func updateTeacher(_ teacher: Teacher) {
        if let index = teachers.firstIndex(where: { $0.id == teacher.id }) {
            teachers[index] = teacher
            notifyUpdate()
        }
        
        Task {
            do {
                try await client.from("teachers").update(teacher).eq("id", value: teacher.id.uuidString).execute()
            } catch {
                print("Failed to update teacher: \(error)")
            }
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
        
        Task {
            do {
                try await client.from("teachers").delete().eq("id", value: id.uuidString).execute()
            } catch {
                print("Failed to delete teacher: \(error)")
            }
        }
    }
    
    // MARK: - Courses
    
    func addCourse(_ course: Course) {
        courses.append(course)
        notifyUpdate()
        
        Task {
            do {
                try await client.from("courses").insert(course).execute()
            } catch {
                print("Failed to add course: \(error)")
            }
        }
    }
    
    func getCourses() -> [Course] { return courses }
    
    func updateCourse(_ course: Course) {
        if let index = courses.firstIndex(where: { $0.id == course.id }) {
            courses[index] = course
            notifyUpdate()
        }
        
        Task {
            do {
                try await client.from("courses").update(course).eq("id", value: course.id.uuidString).execute()
            } catch {
                print("Failed to update course: \(error)")
            }
        }
    }
    
    func deleteCourse(id: UUID) {
        courses.removeAll { $0.id == id }
        notifyUpdate()
        
        Task {
            do {
                try await client.from("courses").delete().eq("id", value: id.uuidString).execute()
            } catch {
                print("Failed to delete course: \(error)")
            }
        }
    }
    
    // MARK: - Course Assignments
    
    func assignTeacherToCourse(teacherId: UUID?, courseId: UUID) {
        if let index = courses.firstIndex(where: { $0.id == courseId }) {
            courses[index].teacherId = teacherId
            notifyUpdate()
            
            Task {
                do {
                    struct TeacherUpdate: Codable { let teacherId: UUID? }
                    try await client.from("courses")
                        .update(TeacherUpdate(teacherId: teacherId))
                        .eq("id", value: courseId.uuidString)
                        .execute()
                } catch {
                    print("Failed to assign teacher: \(error)")
                }
            }
        }
    }
    
    func enrollStudentToCourse(studentId: UUID, courseId: UUID) {
        if let index = courses.firstIndex(where: { $0.id == courseId }) {
            if !courses[index].enrolledStudentIds.contains(studentId) {
                courses[index].enrolledStudentIds.append(studentId)
                let updatedCourse = courses[index]
                notifyUpdate()
                
                Task {
                    do {
                        struct EnrollmentUpdate: Codable { let enrolledStudentIds: [UUID] }
                        try await client.from("courses")
                            .update(EnrollmentUpdate(enrolledStudentIds: updatedCourse.enrolledStudentIds))
                            .eq("id", value: courseId.uuidString)
                            .execute()
                    } catch {
                        print("Failed to enroll student: \(error)")
                    }
                }
            }
        }
    }
    
    func unenrollStudentFromCourse(studentId: UUID, courseId: UUID) {
        if let index = courses.firstIndex(where: { $0.id == courseId }) {
            courses[index].enrolledStudentIds.removeAll { $0 == studentId }
            let updatedCourse = courses[index]
            notifyUpdate()
            
            Task {
                do {
                    struct EnrollmentUpdate: Codable { let enrolledStudentIds: [UUID] }
                    try await client.from("courses")
                        .update(EnrollmentUpdate(enrolledStudentIds: updatedCourse.enrolledStudentIds))
                        .eq("id", value: courseId.uuidString)
                        .execute()
                } catch {
                    print("Failed to unenroll student: \(error)")
                }
            }
        }
    }
}
