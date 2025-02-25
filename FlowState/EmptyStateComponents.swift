import SwiftUI

struct TaskEmptyStateView: View {
    let mood: String
    let showRecommendedTask: Bool
    @ObservedObject var moodSystem: MoodSystem
    @ObservedObject var taskManager: TaskManager
    
    var moodBasedColor: Color {
        switch mood {
        case "Focused": return .blue
        case "Energized": return .orange
        case "Creative": return .purple
        case "Peaceful": return .cyan
        case "Reflective": return .indigo
        case "Tired": return .gray
        default: return .purple
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if showRecommendedTask {
                VStack(spacing: 8) {
                    // Header with color matching mood
                    HStack {
                        Text("Recommended Tasks")
                            .font(.title2)
                            .foregroundColor(moodBasedColor)
                        
                        Spacer()
                        
                        // Page indicators
                        HStack(spacing: 4) {
                            Circle()
                                .fill(moodBasedColor)
                                .frame(width: 6, height: 6)
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 6, height: 6)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recommended task card
                    if let firstTask = moodSystem.suggestTasks(for: mood).first {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: firstTask.category.icon)
                                    .foregroundColor(moodBasedColor)
                                
                                Text(firstTask.title)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(action: {
                                    let newTask = TaskItem(
                                        title: firstTask.title,
                                        isCompleted: false,
                                        priority: .medium,
                                        dueDate: Date(),
                                        mood: firstTask.moodTag
                                    )
                                    taskManager.addTask(newTask)
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.green)
                                }
                            }
                            
                            Text(firstTask.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            
            // Push content to center if no recommendations
            if !showRecommendedTask {
                Spacer()
            }
            
            // Empty state icon and text
            VStack(spacing: 12) {
                Image(systemName: "list.bullet.clipboard")
                    .font(.system(size: 50))
                    .foregroundColor(.gray)

                Text("No tasks yet")
                    .font(.title2.weight(.semibold))

                Text("Tap the + button to add your first task")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxHeight: .infinity, alignment: .center)
            .padding(.bottom, 100)  // Add padding at bottom to maintain spacing
            
            // Spacer at bottom to maintain layout
            Spacer(minLength: 0)
        }
    }
}
