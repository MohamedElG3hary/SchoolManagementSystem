import SwiftUI

struct EnrollmentView: View {
    @ObservedObject var courseVM: CourseViewModel
    @ObservedObject var studentVM: StudentViewModel
    
    @State private var selectedStudentId: UUID?
    
    var body: some View {
        Form {
            Section(header: Text("Select Student")) {
                Picker("Student", selection: $selectedStudentId) {
                    Text("Select a Student").tag(UUID?.none)
                    ForEach(studentVM.students) { student in
                        Text(student.name).tag(UUID?.some(student.id))
                    }
                }
            }
            
            if let studentId = selectedStudentId {
                let availableCourses = courseVM.getAvailableCourses(for: studentId)
                let enrolledCourses = courseVM.getCourses(for: studentId)
                
                Section(header: Text("Available Courses")) {
                    if availableCourses.isEmpty {
                        Text("No more available courses.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(availableCourses) { course in
                            HStack {
                                Text(course.title)
                                Spacer()
                                Button("Enroll") {
                                    courseVM.enrollStudent(studentId: studentId, in: course.id)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
                
                Section(header: Text("My Enrolled Courses")) {
                    if enrolledCourses.isEmpty {
                        Text("Not enrolled in any courses.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(enrolledCourses) { course in
                            HStack {
                                Text(course.title)
                                Spacer()
                                Button("Unenroll") {
                                    courseVM.unenrollStudent(studentId: studentId, from: course.id)
                                }
                                .foregroundColor(.red)
                                .buttonStyle(.borderless)
                            }
                        }
                    }
                }
            } else {
                Section {
                    Text("Please select a student to manage enrollments.")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Enrollment")
    }
}
