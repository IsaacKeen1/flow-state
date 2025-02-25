import SwiftUI

struct MoodCheckView: View {
    let colors = CustomColors()
    @Environment(\.dismiss) var dismiss
    @State private var selectedMood: String?
    @State private var isAnimating = false
   
    // Updated mood selections with new moods
    let moods: [(name: String, emoji: String, color: Color)] = [
        ("Happy", "😊", Color(red: 255/255, green: 247/255, blue: 174/255)),
        ("Productive", "💪", Color(red: 210/255, green: 241/255, blue: 228/255)),
        ("Stressed", "😰", Color(red: 216/255, green: 230/255, blue: 255/255)),
        ("Tired", "😴", Color(red: 240/255, green: 230/255, blue: 250/255)),
        ("Bored", "😑", Color(red: 255/255, green: 215/255, blue: 181/255)),
        ("Sad", "😢", Color(red: 250/255, green: 212/255, blue: 216/255))
    ]
   
    var body: some View {
        ZStack {
            // Sophisticated background
            RadialGradient(
                gradient: Gradient(colors: [colors.accent, colors.primary]),
                center: .topLeading,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.width)
                .ignoresSafeArea()
           
            // Content
            VStack(alignment: .leading, spacing: 0) {
                // Custom back button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .padding()
                }
               
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 25) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("How are you feeling?")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                            Text("Select your current state of mind")
                                .font(.title3.weight(.medium))
                                .opacity(0.8)
                        }
                        .foregroundStyle(.white)
                        .padding(.leading)
                        .padding(.top, 20)
                       
                        // Mood Grid
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 15),
                                GridItem(.flexible(), spacing: 15)
                            ],
                            spacing: 15
                        ) {
                            ForEach(moods, id: \.name) { mood in
                                MoodButton(
                                    mood: mood.name,
                                    emoji: mood.emoji,
                                    accentColor: mood.color,
                                    isSelected: selectedMood == mood.name,
                                    action: { selectedMood = mood.name }
                                )
                                .offset(y: isAnimating ? 0 : 50)
                                .opacity(isAnimating ? 1 : 0)
                                .animation(
                                    .spring(
                                        response: 0.6,
                                        dampingFraction: 0.8
                                    ).delay(Double(moods.firstIndex(where: { $0.name == mood.name })!) * 0.1),
                                    value: isAnimating
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
               
                // Continue Button
                if let selectedMood = selectedMood {
                    Button {
                        dismiss()
                        let taskView = TaskView(mood: selectedMood)
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController = UIHostingController(rootView: taskView)
                        }
                    } label: {
                        Text("Continue")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(colors.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                            .padding()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
}

struct MoodButton: View {
    let mood: String
    let emoji: String
    let accentColor: Color
    let isSelected: Bool
    let action: () -> Void
   
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 60, height: 60)
                   
                    Text(emoji)
                        .font(.system(size: 30))
                }
               
                Text(mood)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background {
                RoundedRectangle(cornerRadius: 25)
                    .fill(.white.opacity(0.1))
                    .overlay {
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(.white.opacity(isSelected ? 0.5 : 0.2), lineWidth: 1)
                    }
                    .shadow(color: accentColor.opacity(isSelected ? 0.3 : 0), radius: 15)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

#Preview {
   MoodCheckView()
}
