import SwiftUI

// EditTaskSheet Component
struct EditTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    let task: TaskItem
    let onUpdate: (TaskItem) -> Void
    
    @State private var taskTitle: String
    @State private var selectedPriority: TaskItem.Priority
    @State private var dueDate: Date
    @State private var showDatePicker = false
    
    init(task: TaskItem, onUpdate: @escaping (TaskItem) -> Void) {
        self.task = task
        self.onUpdate = onUpdate
        _taskTitle = State(initialValue: task.title)
        _selectedPriority = State(initialValue: task.priority)
        _dueDate = State(initialValue: task.dueDate ?? Date())
    }
    
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
                    Button("Save Changes") {
                        var updatedTask = task
                        updatedTask.title = taskTitle
                        updatedTask.priority = selectedPriority
                        updatedTask.dueDate = dueDate
                        onUpdate(updatedTask)
                        dismiss()
                    }
                    .disabled(taskTitle.isEmpty)
                }
            }
            .navigationTitle("Edit Task")
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

struct TaskRow: View {
    let task: TaskItem
    let onDelete: (TaskItem) -> Void
    let onUpdate: (TaskItem) -> Void
    @Binding var isVisible: Bool
    @State private var showingCheckmark: Bool
    let moodColor: Color
    @State private var showingEditSheet = false

    init(task: TaskItem, moodColor: Color, isVisible: Binding<Bool>, onDelete: @escaping (TaskItem) -> Void, onUpdate: @escaping (TaskItem) -> Void) {
        self.task = task
        self.moodColor = moodColor
        self._isVisible = isVisible
        self.onDelete = onDelete
        self.onUpdate = onUpdate
        self._showingCheckmark = State(initialValue: task.isCompleted)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            ZStack {
                Circle()
                    .stroke(lineWidth: 2)
                    .foregroundColor(showingCheckmark ? moodColor : .gray)
                    .frame(width: 30, height: 30)
                
                if showingCheckmark {
                    Circle()
                        .fill(moodColor)
                        .frame(width: 30, height: 30)
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .onTapGesture {
                handleTaskToggle()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(showingCheckmark, color: moodColor)
                
                if let dueDate = task.dueDate {
                    Text(dueDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if !showingCheckmark {
                Circle()
                    .fill(task.priority.color)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .opacity(isVisible ? 1 : 0)
        .sheet(isPresented: $showingEditSheet) {
            EditTaskSheet(task: task, onUpdate: onUpdate)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation {
                    isVisible = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDelete(task)
                    }
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                showingEditSheet = true
            } label: {
                Label("Edit", systemImage: "square.and.pencil")
            }
            .tint(.indigo)
        }
    }
    
    private func handleTaskToggle() {
        if showingCheckmark {
            showingCheckmark = false
            var updatedTask = task
            updatedTask.isCompleted = false
            onUpdate(updatedTask)
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingCheckmark = true
                var updatedTask = task
                updatedTask.isCompleted = true
                onUpdate(updatedTask)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    isVisible = false
                }
            }
        }
    }
}
