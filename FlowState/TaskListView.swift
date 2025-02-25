import Foundation
import SwiftUI

struct TaskListView: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var moodSystem: MoodSystem
    let currentMood: String
    let moodBasedColor: Color
    let selectedFilter: TaskFilter
    @Binding var currentPage: Int
    @Binding var taskVisibility: [UUID: Bool]
    
    var body: some View {
        if selectedFilter == .completed {
            List {
                Section {
                    StatisticsView(taskManager: taskManager, moodColor: moodBasedColor)
                        .padding(.top, 16)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
                
                ForEach(taskManager.completedTasks) { task in
                    TaskRow(
                        task: task,
                        moodColor: moodBasedColor,
                        isVisible: Binding(
                            get: { taskVisibility[task.id] ?? true },
                            set: { taskVisibility[task.id] = $0 }
                        ),
                        onDelete: taskManager.deleteTask,
                        onUpdate: taskManager.updateTask
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .background(Color.white)
        } else {
            List {
                if selectedFilter != .completed && (selectedFilter == .all || selectedFilter == .today) {
                    Section {
                        TaskRecommendationsViewSlim(
                            moodSystem: moodSystem,
                            taskManager: taskManager,
                            currentMood: currentMood,
                            currentPage: $currentPage
                        )
                        .padding(.vertical, 16)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                
                ForEach(taskManager.tasks.filter { filterTask($0) }) { task in
                    TaskRow(
                        task: task,
                        moodColor: moodBasedColor,
                        isVisible: Binding(
                            get: { taskVisibility[task.id] ?? true },
                            set: { taskVisibility[task.id] = $0 }
                        ),
                        onDelete: taskManager.deleteTask,
                        onUpdate: taskManager.updateTask
                    )
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .background(Color.white)
        }
    }
    
    private func filterTask(_ task: TaskItem) -> Bool {
        switch selectedFilter {
        case .all:
            return true
        case .today:
            guard let dueDate = task.dueDate else { return false }
            return Calendar.current.isDateInToday(dueDate)
        case .upcoming:
            guard let dueDate = task.dueDate else { return false }
            return Calendar.current.isDateInTomorrow(dueDate) ||
                   (Calendar.current.compare(dueDate, to: Date(), toGranularity: .day) == .orderedDescending)
        case .completed:
            return false
        }
    }
}
