import SwiftUI

struct CustomColors {
    let primary = Color(red: 41/255, green: 128/255, blue: 185/255)  // Rich blue
    let accent = Color(red: 52/255, green: 152/255, blue: 219/255)   // Vibrant blue
    let neutral = Color(red: 236/255, green: 240/255, blue: 241/255) // Soft white
}

struct ParticlesView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let now = timeline.date.timeIntervalSinceReferenceDate
                let angle = Angle.degrees(now.remainder(dividingBy: 3) * 120)
                _ = cos(angle.radians)
                _ = sin(angle.radians)
                
                context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
                context.rotate(by: angle)
                context.translateBy(x: -size.width * 0.5, y: -size.height * 0.5)
                
                let particles = 8
                for index in 0..<particles {
                    let position = CGPoint(
                        x: size.width * 0.5 + CGFloat(cos(Double(index) / Double(particles)) * 50),
                        y: size.height * 0.5 + CGFloat(sin(Double(index) / Double(particles)) * 50)
                    )
                    
                    let path = Path { p in
                        p.addEllipse(in: CGRect(x: position.x, y: position.y, width: 4, height: 4))
                    }
                    
                    context.fill(path, with: .color(.white.opacity(0.5)))
                }
            }
        }
    }
}

struct ContentView: View {
    @State private var showingMoodCheck = false
    @State private var breatheIn = false
    
    let colors = CustomColors()
    
    var body: some View {
        ZStack {
            // Complex gradient background
            RadialGradient(
                gradient: Gradient(colors: [colors.accent, colors.primary]),
                center: .topLeading,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.width)
                .ignoresSafeArea()
            
            // Subtle particles
            ParticlesView()
                .opacity(0.15)
            
            VStack(spacing: 50) {
                Spacer()
                
                // Simplified logo area
                Text("FlowState")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                // Refined breathing circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .stroke(Color.white.opacity(0.6), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(breatheIn ? 1.2 : 0.8)
                        .opacity(breatheIn ? 0.3 : 0.8)
                }
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: breatheIn)
                
                Spacer()
                
                // Modern action button
                Button {
                    showingMoodCheck = true
                } label: {
                    Text("Begin")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(colors.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(.white)
                        .clipShape(Capsule())
                        .padding(.horizontal, 40)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear { breatheIn = true }
        .fullScreenCover(isPresented: $showingMoodCheck) {
            MoodCheckView()
        }
    }
}

#Preview {
    ContentView()
}
