import SwiftUI

struct StudentsView: View {
    @ObservedObject var viewModel: StudentViewModel
    @State private var newStudentName = ""
    
    var body: some View {
        Form {
            Section(header: Text("Add New Student")) {
                TextField("Student Name", text: $newStudentName)
                Button("Add Student") {
                    viewModel.addStudent(name: newStudentName)
                    newStudentName = ""
                }
                .disabled(newStudentName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            
            Section(header: Text("All Students")) {
                if viewModel.students.isEmpty {
                    Text("No students found.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(viewModel.students) { student in
                        Text(student.name)
                    }
                    .onDelete(perform: viewModel.deleteStudent)
                }
            }
        }
        .navigationTitle("Students")
    }
}
