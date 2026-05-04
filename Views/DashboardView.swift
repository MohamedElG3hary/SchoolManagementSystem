import SwiftUI

struct DashboardView: View {
    let database: DatabaseServiceProtocol
    
    @StateObject private var studentVM: StudentViewModel
    @StateObject private var teacherVM: TeacherViewModel
    @StateObject private var courseVM: CourseViewModel
    
    init(database: DatabaseServiceProtocol) {
        self.database = database
        _studentVM = StateObject(wrappedValue: StudentViewModel(database: database))
        _teacherVM = StateObject(wrappedValue: TeacherViewModel(database: database))
        _courseVM = StateObject(wrappedValue: CourseViewModel(database: database))
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Admin Features")) {
                    NavigationLink(destination: StudentsView(viewModel: studentVM)) {
                        Label("Manage Students", systemImage: "person.3")
                    }
                    NavigationLink(destination: TeachersView(viewModel: teacherVM, courseVM: courseVM)) {
                        Label("Manage Teachers", systemImage: "briefcase")
                    }
                    NavigationLink(destination: CoursesView(courseVM: courseVM, teacherVM: teacherVM, studentVM: studentVM)) {
                        Label("Manage Courses", systemImage: "book")
                    }
                }
                
                Section(header: Text("Student Features")) {
                    NavigationLink(destination: EnrollmentView(courseVM: courseVM, studentVM: studentVM)) {
                        Label("Course Enrollment", systemImage: "graduationcap")
                    }
                }
                
                Section(header: Text("Teacher Features")) {
                    NavigationLink(destination: TeachersView(viewModel: teacherVM, courseVM: courseVM)) {
                        Label("View Assigned Courses", systemImage: "list.clipboard")
                    }
                }
            }
            .navigationTitle("School Manager")
        }
    }
}
