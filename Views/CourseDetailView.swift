import SwiftUI

struct CourseDetailView: View {
    var course: Course
    @ObservedObject var courseVM: CourseViewModel
    @ObservedObject var teacherVM: TeacherViewModel
    @ObservedObject var studentVM: StudentViewModel
    
    @State private var selectedTeacherId: UUID?
    
    var body: some View {
        // Find the latest course data because it might have been updated
        let currentCourse = courseVM.courses.first(where: { $0.id == course.id }) ?? course
        let enrolledStudents = courseVM.getEnrolledStudents(for: currentCourse, from: studentVM.students)
        
        Form {
            Section(header: Text("Course Info")) {
                Text(currentCourse.title)
                    .font(.title2)
                    .bold()
            }
            
            Section(header: Text("Assign Teacher")) {
                Picker("Select Teacher", selection: $selectedTeacherId) {
                    Text("Unassigned").tag(UUID?.none)
                    ForEach(teacherVM.teachers) { teacher in
                        Text(teacher.name).tag(UUID?.some(teacher.id))
                    }
                }
                
                Button("Save Teacher Assignment") {
                    courseVM.assignTeacher(teacherId: selectedTeacherId, to: currentCourse.id)
                }
                .disabled(selectedTeacherId == currentCourse.teacherId)
            }
            
            Section(header: Text("Enrolled Students (\(enrolledStudents.count))")) {
                if enrolledStudents.isEmpty {
                    Text("No students enrolled.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(enrolledStudents) { student in
                        HStack {
                            Text(student.name)
                            Spacer()
                            Button(role: .destructive) {
                                courseVM.unenrollStudent(studentId: student.id, from: currentCourse.id)
                            } label: {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
        }
        .navigationTitle("Course Details")
        .onAppear {
            selectedTeacherId = currentCourse.teacherId
        }
    }
}
