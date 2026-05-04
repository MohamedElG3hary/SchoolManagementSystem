import SwiftUI

struct CoursesView: View {
    @ObservedObject var courseVM: CourseViewModel
    @ObservedObject var teacherVM: TeacherViewModel
    @ObservedObject var studentVM: StudentViewModel
    @State private var newCourseTitle = ""
    
    var body: some View {
        Form {
            Section(header: Text("Add New Course")) {
                TextField("Course Title", text: $newCourseTitle)
                Button("Add Course") {
                    courseVM.addCourse(title: newCourseTitle)
                    newCourseTitle = ""
                }
                .disabled(newCourseTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            
            Section(header: Text("All Courses")) {
                if courseVM.courses.isEmpty {
                    Text("No courses found.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(courseVM.courses) { course in
                        NavigationLink(destination: CourseDetailView(course: course, courseVM: courseVM, teacherVM: teacherVM, studentVM: studentVM)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(course.title).font(.headline)
                                if let teacherId = course.teacherId, let teacher = teacherVM.teachers.first(where: { $0.id == teacherId }) {
                                    Text("Teacher: \(teacher.name)").font(.subheadline).foregroundColor(.secondary)
                                } else {
                                    Text("No Teacher Assigned").font(.subheadline).foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .onDelete(perform: courseVM.deleteCourse)
                }
            }
        }
        .navigationTitle("Courses")
    }
}
