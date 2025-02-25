import SwiftUI

struct StatisticsView: View {
    @ObservedObject var taskManager: TaskManager
    let moodColor: Color
    @State private var showingClearAlert = false
    
    var totalTasksCompleted: Int {
        taskManager.completedTasks.count
    }
    
    var dailyTasksCompleted: Int {
        let calendar = Calendar.current
        return taskManager.completedTasks.filter { task in
            calendar.isDateInToday(task.dueDate ?? Date())
        }.count
    }
    
    // Define all possible moods to ensure they're always displayed
    let allMoods = ["Happy", "Productive", "Stressed", "Tired", "Bored", "Sad"]
    
    var tasksByMood: [String: Int] {
        var stats = Dictionary(grouping: taskManager.completedTasks, by: { $0.mood ?? "Unknown" })
            .mapValues { $0.count }
        
        // Ensure all moods have a value (0 if no tasks)
        for mood in allMoods {
            if stats[mood] == nil {
                stats[mood] = 0
            }
        }
        return stats
    }
    
    var mostProductiveMood: String? {
        taskManager.moodStats.max(by: { $0.value < $1.value })?.key
    }
    
    var maxTaskCount: Int {
        max(5, tasksByMood.values.max() ?? 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) { // Increased overall spacing
            // Overview Cards
            HStack(spacing: 16) { // Increased spacing between cards
                // Total Completed Card
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(moodColor)
                        .font(.system(size: 24))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(totalTasksCompleted)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Total Completed")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                // Today's Completed Card
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .foregroundColor(moodColor)
                        .font(.system(size: 24))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(dailyTasksCompleted)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Today's Completed")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
            }
            .padding(.horizontal)
            
            // Mood Analysis
            VStack(alignment: .leading, spacing: 16) {
                Text("Task Analysis by Mood")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                
                if let mostProductive = mostProductiveMood {
                    Text("Most Productive: \(getMoodEmoji(mostProductive))")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Graph
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(allMoods, id: \.self) { mood in
                        VStack(spacing: 8) {
                            // Bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(getMoodColor(mood))
                                .frame(width: 6, height: CGFloat(tasksByMood[mood] ?? 0) / CGFloat(maxTaskCount) * 150) // Adjusted height multiplier
                            
                            // Task count
                            Text("\(tasksByMood[mood] ?? 0)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            // Emoji label
                            Text(getMoodEmoji(mood))
                                .font(.system(size: 16))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 200) // Adjusted frame height to 3/4 size
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .padding(.vertical, 20)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.horizontal)
            
            // Clear Button
            if !taskManager.completedTasks.isEmpty {
                Button(action: {
                    showingClearAlert = true
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 16))
                        Text("Clear All Completed Tasks")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .alert(isPresented: $showingClearAlert) {
                    Alert(
                        title: Text("Clear Completed Tasks"),
                        message: Text("Are you sure you want to clear all completed tasks and reset the analysis?"),
                        primaryButton: .destructive(Text("Clear All")) {
                            taskManager.clearCompletedTasks()
                            taskManager.resetMoodStats()
                        },
                        secondaryButton: .cancel()
                    )
                }
                .padding(.horizontal)
            }
        }
    }
    
    func getMoodEmoji(_ mood: String) -> String {
        switch mood {
        case "Happy": return "😊"
        case "Productive": return "💪"
        case "Stressed": return "😰"
        case "Tired": return "😴"
        case "Bored": return "😑"
        case "Sad": return "😢"
        default: return "💪"
        }
    }
    
    func getMoodColor(_ mood: String) -> Color {
        switch mood {
        case "Happy": return Color(red: 255/255, green: 223/255, blue: 0/255)      // Bright yellow
        case "Productive": return Color(red: 255/255, green: 149/255, blue: 0/255)  // Bright orange
        case "Stressed": return Color(red: 0/255, green: 122/255, blue: 255/255)    // Bright blue
        case "Tired": return Color(red: 191/255, green: 90/255, blue: 242/255)      // Bright purple
        case "Bored": return Color(red: 255/255, green: 159/255, blue: 10/255)      // Saturated orange
        case "Sad": return Color(red: 88/255, green: 86/255, blue: 214/255)         // Vibrant indigo
        default: return Color(red: 255/255, green: 149/255, blue: 0/255)            // Default bright orange
        }
    }
}
