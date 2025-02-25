import SwiftUI

struct TaskRecommendationsView: View {
    @ObservedObject var moodSystem: MoodSystem
    let currentMood: String
    @State private var currentPage: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Recommended Tasks")
                .font(.title2.bold())
                .padding(.horizontal)

            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(Array(moodSystem.suggestTasks(for: currentMood).enumerated()), id: \.element.id) { index, suggestion in
                            TaskSuggestionCard(suggestion: suggestion)
                                .frame(width: 250) // Fixed width for each card
                                .onAppear {
                                    withAnimation {
                                        currentPage = index
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                }

                PageIndicator(totalPages: moodSystem.suggestTasks(for: currentMood).count, currentPage: currentPage)
                    .padding(.top, 8)
            }
        }
    }
}

struct TaskSuggestionCard: View {
    let suggestion: TaskSuggestionModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category and Duration
            HStack {
                Image(systemName: suggestion.category.icon)
                    .foregroundColor(.blue)
                Spacer()
                Text(formatDuration(suggestion.estimatedDuration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Title
            Text(suggestion.title)
                .font(.headline)
                .foregroundColor(.primary)

            // Description
            Text(suggestion.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)

            // Energy Level Indicator
            HStack {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(index < suggestion.energyRequired ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .padding()
        .frame(width: 250)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        return "\(minutes) min"
    }
}

struct PageIndicator: View {
    let totalPages: Int
    let currentPage: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.primary : Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
            }
        }
    }
}
