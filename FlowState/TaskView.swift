import SwiftUI
import Foundation

struct TaskView: View {
    @StateObject private var moodSystem = MoodSystem()
    @StateObject private var taskManager = TaskManager()
    @State private var showingAddTask = false
    @State private var selectedFilter: TaskFilter = .all
    @State private var currentMood: String
    @State private var showMoodSelector = false
    @State private var currentPage = 0
    @State private var taskVisibility: [UUID: Bool] = [:]

    init(mood: String) {
        _currentMood = State(initialValue: mood)
    }

    var moodBasedColor: Color {
        switch currentMood {
        case "Happy": return Color(red: 255/255, green: 223/255, blue: 0/255)
        case "Productive": return Color(red: 255/255, green: 149/255, blue: 0/255)
        case "Stressed": return Color(red: 0/255, green: 122/255, blue: 255/255)
        case "Tired": return Color(red: 191/255, green: 90/255, blue: 242/255)
        case "Bored": return Color(red: 255/255, green: 159/255, blue: 10/255)
        case "Sad": return Color(red: 88/255, green: 86/255, blue: 214/255)
        default: return Color(red: 255/255, green: 149/255, blue: 0/255)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    FilterButtonsView(selectedFilter: $selectedFilter)
                    
                    if taskManager.tasks.isEmpty && taskManager.completedTasks.isEmpty {
                        EmptyStateView(
                            moodSystem: moodSystem,
                            taskManager: taskManager,
                            currentMood: currentMood,
                            currentPage: $currentPage,
                            selectedFilter: selectedFilter
                        )
                    } else {
                        TaskListView(
                            taskManager: taskManager,
                            moodSystem: moodSystem,
                            currentMood: currentMood,
                            moodBasedColor: moodBasedColor,
                            selectedFilter: selectedFilter,
                            currentPage: $currentPage,
                            taskVisibility: $taskVisibility
                        )
                    }
                }

                FloatingActionButtons(
                    showMoodSelector: $showMoodSelector,
                    showingAddTask: $showingAddTask,
                    moodBasedColor: moodBasedColor,
                    currentMood: currentMood
                )
            }
            .navigationTitle("My Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddTask) {
                AddTaskSheet(taskManager: taskManager, currentMood: currentMood)
            }
            .sheet(isPresented: $showMoodSelector) {
                MoodCheckView()
            }
        }
    }
}
