import SwiftUI

struct TeachersView: View {
    @ObservedObject var viewModel: TeacherViewModel
    @ObservedObject var courseVM: CourseViewModel
    @State private var newTeacherName = ""
    
    var body: some View {
        Form {
            Section(header: Text("Add New Teacher")) {
                TextField("Teacher Name", text: $newTeacherName)
                Button("Add Teacher") {
                    viewModel.addTeacher(name: newTeacherName)
                    newTeacherName = ""
                }
                .disabled(newTeacherName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            
            Section(header: Text("All Teachers")) {
                if viewModel.teachers.isEmpty {
                    Text("No teachers found.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.teachers) { teacher in
                        NavigationLink(destination: TeacherAssignedCoursesView(teacher: teacher, courseVM: courseVM)) {
                            Text(teacher.name)
                        }
                    }
                    .onDelete(perform: viewModel.deleteTeacher)
                }
            }
        }
        .navigationTitle("Teachers")
    }
}

struct TeacherAssignedCoursesView: View {
    var teacher: Teacher
    @ObservedObject var courseVM: CourseViewModel
    
    var body: some View {
        let assignedCourses = courseVM.getCourses(for: teacher.id)
        
        List {
            if assignedCourses.isEmpty {
                Text("No courses assigned to this teacher yet.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(assignedCourses) { course in
                    Text(course.title)
                }
            }
        }
        .navigationTitle("\(teacher.name)'s Courses")
    }
}
