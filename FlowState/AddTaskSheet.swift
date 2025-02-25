import SwiftUI
import Foundation

struct AddTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var taskManager: TaskManager
    let currentMood: String
    
    @State private var taskTitle = ""
    @State private var selectedPriority: TaskItem.Priority = .medium
    @State private var dueDate = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Task name", text: $taskTitle)
                    
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskItem.Priority.allCases, id: \.self) { priority in
                            Label(priority.rawValue, systemImage: "flag.fill")
                                .foregroundColor(priority.color)
                                .tag(priority)
                        }
                    }
                    
                    Button {
                        showDatePicker.toggle()
                    } label: {
                        HStack {
                            Text("Due Date")
                            Spacer()
                            Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if showDatePicker {
                        DatePicker("Select date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.graphical)
                    }
                }
                
                Section {
                    Button("Add Task") {
                        let task = TaskItem(
                            title: taskTitle,
                            isCompleted: false,
                            priority: selectedPriority,
                            dueDate: dueDate,
                            mood: currentMood
                        )
                        taskManager.addTask(task)
                        dismiss()
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
