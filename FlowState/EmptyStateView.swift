import SwiftUI

struct EmptyStateView: View {
    @ObservedObject var moodSystem: MoodSystem
    @ObservedObject var taskManager: TaskManager
    let currentMood: String
    @Binding var currentPage: Int
    let selectedFilter: TaskFilter
    
    var body: some View {
        VStack {
            if selectedFilter != .completed && (selectedFilter == .all || selectedFilter == .today) {
                TaskRecommendationsViewSlim(
                    moodSystem: moodSystem,
                    taskManager: taskManager,
                    currentMood: currentMood,
                    currentPage: $currentPage
                )
                .padding(.bottom, 16)
            }
            
            Spacer()
            
            Image(systemName: "list.bullet.clipboard")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding(.bottom, 4)

            Text("No tasks yet")
                .font(.title2.weight(.semibold))

            Text("Tap the + button to add your first task")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}
