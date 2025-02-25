import SwiftUI

struct FloatingActionButtons: View {
    @Binding var showMoodSelector: Bool
    @Binding var showingAddTask: Bool
    let moodBasedColor: Color
    let currentMood: String
    
    private func getMoodEmoji(_ mood: String) -> String {
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
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    Button(action: {
                        showMoodSelector = true
                    }) {
                        Text(getMoodEmoji(currentMood))
                            .font(.system(size: 24))
                            .frame(width: 56, height: 56)
                            .background(moodBasedColor)
                            .clipShape(Circle())
                            .shadow(color: moodBasedColor.opacity(0.3), radius: 10, y: 5)
                    }

                    Button {
                        showingAddTask = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(moodBasedColor)
                            .clipShape(Circle())
                            .shadow(color: moodBasedColor.opacity(0.3), radius: 10, y: 5)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 30)
            }
        }
    }
}
