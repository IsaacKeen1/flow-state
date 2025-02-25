import SwiftUI

struct TaskRecommendationsViewSlim: View {
    @ObservedObject var moodSystem: MoodSystem
    @ObservedObject var taskManager: TaskManager
    let currentMood: String
    @Binding var currentPage: Int

    var moodBasedColor: Color {
        switch currentMood {
        case "Happy": return Color(red: 255/255, green: 223/255, blue: 0/255)      // Bright yellow
        case "Productive": return Color(red: 255/255, green: 149/255, blue: 0/255)  // Bright orange
        case "Stressed": return Color(red: 0/255, green: 122/255, blue: 255/255)    // Bright blue
        case "Tired": return Color(red: 191/255, green: 90/255, blue: 242/255)      // Bright purple
        case "Bored": return Color(red: 255/255, green: 159/255, blue: 10/255)      // Saturated orange
        case "Sad": return Color(red: 88/255, green: 86/255, blue: 214/255)         // Vibrant indigo
        default: return Color(red: 255/255, green: 149/255, blue: 0/255)            // Default bright orange
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recommended Tasks")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(moodBasedColor)
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(0..<moodSystem.suggestTasks(for: currentMood).count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? moodBasedColor : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .padding(.horizontal)

            TabView(selection: $currentPage) {
                ForEach(moodSystem.suggestTasks(for: currentMood)) { suggestion in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: suggestion.category.icon)
                                .foregroundColor(moodBasedColor)
                            Spacer()
                            Button(action: {
                                let newTask = TaskItem(
                                    title: suggestion.title,
                                    isCompleted: false,
                                    priority: .medium,
                                    dueDate: Date(),
                                    mood: suggestion.moodTag
                                )
                                taskManager.addTask(newTask)
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.green)
                            }
                        }

                        Text(suggestion.title)
                            .font(.body.weight(.medium))
                            .lineLimit(1)

                        Text(suggestion.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(8)
                    .frame(width: UIScreen.main.bounds.width - 80)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(moodBasedColor.opacity(0.3), lineWidth: 1)
                    )
                    .tag(suggestion.id)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 160)
            .padding(.horizontal)
        }
    }
}
