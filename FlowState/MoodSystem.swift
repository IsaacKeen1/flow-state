// MoodSystem.swift
import SwiftUI

// MARK: - Task Categories and Types
enum TaskTimeOfDay: CaseIterable, Codable {
    case morning
    case afternoon
    case evening
}

enum TaskCategoryType: CaseIterable, Codable {
    case work
    case creative
    case focus
    case maintenance
    case planning
    case social

    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .creative: return "lightbulb.fill"
        case .focus: return "target"
        case .maintenance: return "wrench.fill"
        case .planning: return "calendar"
        case .social: return "person.2.fill"
        }
    }
}

// MARK: - Task Suggestion Model
struct TaskSuggestionModel: Identifiable, Hashable, Codable {
    var id = UUID()
    let title: String
    let priority: TaskItem.Priority
    let estimatedDuration: TimeInterval
    let energyRequired: Int
    let bestTimeOfDay: TaskTimeOfDay
    let category: TaskCategoryType
    let moodTag: String
    let description: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: TaskSuggestionModel, rhs: TaskSuggestionModel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Mood System
class MoodSystem: ObservableObject {
    @Published var currentMood: Mood?
    @Published var moodHistory: [MoodEntry] = []

    struct Mood: Identifiable, Codable {
        let id = UUID()
        let name: String
        let emoji: String
        let energyLevel: Int // 1-5
        let focusLevel: Int // 1-5
        let suggestedActivities: [String]
        let color: Color

        enum CodingKeys: String, CodingKey {
            case id, name, emoji, energyLevel, focusLevel, suggestedActivities
        }

        init(name: String, emoji: String, energyLevel: Int, focusLevel: Int, suggestedActivities: [String], color: Color) {
            self.name = name
            self.emoji = emoji
            self.energyLevel = energyLevel
            self.focusLevel = focusLevel
            self.suggestedActivities = suggestedActivities
            self.color = color
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            emoji = try container.decode(String.self, forKey: .emoji)
            energyLevel = try container.decode(Int.self, forKey: .energyLevel)
            focusLevel = try container.decode(Int.self, forKey: .focusLevel)
            suggestedActivities = try container.decode([String].self, forKey: .suggestedActivities)
            color = .clear // Default value since Color isn't Codable
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(emoji, forKey: .emoji)
            try container.encode(energyLevel, forKey: .energyLevel)
            try container.encode(focusLevel, forKey: .focusLevel)
            try container.encode(suggestedActivities, forKey: .suggestedActivities)
        }
        
        var taskStrategy: String {
            switch name {
            case "Happy": return "Channel your positivity into meaningful tasks"
            case "Productive": return "Perfect time for challenging work and important tasks"
            case "Stressed": return "Focus on manageable tasks to reduce overwhelm"
            case "Tired": return "Take it easy with simple, low-energy tasks"
            case "Bored": return "Try something new or creative to re-engage"
            case "Sad": return "Be gentle with yourself, focus on small wins"
            default: return "Take tasks one step at a time"
            }
        }
    }

    struct MoodEntry: Identifiable, Codable {
        var id = UUID()
        let mood: String
        let timestamp: Date
        let completedTasks: Int
        let productivityScore: Int
    }

    // Updated colors to match vibrant scheme
    static let moodColors: [String: Color] = [
        "Happy": Color(red: 255/255, green: 223/255, blue: 0/255),      // Bright yellow
        "Productive": Color(red: 255/255, green: 149/255, blue: 0/255),  // Bright orange
        "Stressed": Color(red: 0/255, green: 122/255, blue: 255/255),    // Bright blue
        "Tired": Color(red: 191/255, green: 90/255, blue: 242/255),      // Bright purple
        "Bored": Color(red: 255/255, green: 159/255, blue: 10/255),      // Saturated orange
        "Sad": Color(red: 88/255, green: 86/255, blue: 214/255)          // Vibrant indigo
    ]

    let moods: [Mood] = [
        Mood(name: "Happy",
             emoji: "😊",
             energyLevel: 5,
             focusLevel: 4,
             suggestedActivities: [
                "Set ambitious goals",
                "Help others with tasks",
                "Take on new challenges",
                "Social activities"
             ],
             color: moodColors["Happy"] ?? .yellow),

        Mood(name: "Productive",
             emoji: "💪",
             energyLevel: 5,
             focusLevel: 5,
             suggestedActivities: [
                "Important deadlines",
                "Complex problem solving",
                "Project planning",
                "Deep work sessions"
             ],
             color: moodColors["Productive"] ?? .orange),

        Mood(name: "Stressed",
             emoji: "😰",
             energyLevel: 3,
             focusLevel: 2,
             suggestedActivities: [
                "Break tasks into smaller steps",
                "Organize workspace",
                "Quick wins",
                "Breathing exercises"
             ],
             color: moodColors["Stressed"] ?? .blue),

        Mood(name: "Tired",
             emoji: "😴",
             energyLevel: 1,
             focusLevel: 2,
             suggestedActivities: [
                "Simple tasks",
                "Review work",
                "Light organization",
                "Self-care activities"
             ],
             color: moodColors["Tired"] ?? .purple),

        Mood(name: "Bored",
             emoji: "😑",
             energyLevel: 3,
             focusLevel: 2,
             suggestedActivities: [
                "Learn something new",
                "Creative projects",
                "Change of environment",
                "Brainstorming sessions"
             ],
             color: moodColors["Bored"] ?? .orange),

        Mood(name: "Sad",
             emoji: "😢",
             energyLevel: 2,
             focusLevel: 2,
             suggestedActivities: [
                "Gentle, manageable tasks",
                "Mood-lifting activities",
                "Connect with others",
                "Self-care routines"
             ],
             color: moodColors["Sad"] ?? .indigo)
    ]

    func suggestTasks(for mood: String) -> [TaskSuggestionModel] {
        switch mood {
        case "Happy":
            return [
                TaskSuggestionModel(
                    title: "Take on a Challenge",
                    priority: .high,
                    estimatedDuration: 3600,
                    energyRequired: 5,
                    bestTimeOfDay: .morning,
                    category: .focus,
                    moodTag: mood,
                    description: "Tackle a challenging task while feeling optimistic"
                ),
                TaskSuggestionModel(
                    title: "Share Your Energy",
                    priority: .medium,
                    estimatedDuration: 1800,
                    energyRequired: 4,
                    bestTimeOfDay: .afternoon,
                    category: .social,
                    moodTag: mood,
                    description: "Help others or engage in team activities"
                )
            ]
            
        case "Productive":
            return [
                TaskSuggestionModel(
                    title: "Important Project",
                    priority: .high,
                    estimatedDuration: 3600,
                    energyRequired: 5,
                    bestTimeOfDay: .morning,
                    category: .work,
                    moodTag: mood,
                    description: "Focus on high-priority tasks requiring concentration"
                ),
                TaskSuggestionModel(
                    title: "Strategic Planning",
                    priority: .high,
                    estimatedDuration: 2400,
                    energyRequired: 4,
                    bestTimeOfDay: .afternoon,
                    category: .planning,
                    moodTag: mood,
                    description: "Plan and organize upcoming projects"
                )
            ]
            
        case "Stressed":
            return [
                TaskSuggestionModel(
                    title: "Small Steps",
                    priority: .medium,
                    estimatedDuration: 900,
                    energyRequired: 2,
                    bestTimeOfDay: .morning,
                    category: .maintenance,
                    moodTag: mood,
                    description: "Break down larger tasks into manageable pieces"
                ),
                TaskSuggestionModel(
                    title: "Organize Space",
                    priority: .low,
                    estimatedDuration: 1200,
                    energyRequired: 2,
                    bestTimeOfDay: .afternoon,
                    category: .maintenance,
                    moodTag: mood,
                    description: "Clear your environment to reduce stress"
                )
            ]
            
        case "Tired":
            return [
                TaskSuggestionModel(
                    title: "Easy Tasks",
                    priority: .low,
                    estimatedDuration: 900,
                    energyRequired: 1,
                    bestTimeOfDay: .morning,
                    category: .maintenance,
                    moodTag: mood,
                    description: "Focus on simple, low-energy tasks"
                ),
                TaskSuggestionModel(
                    title: "Light Review",
                    priority: .low,
                    estimatedDuration: 1200,
                    energyRequired: 1,
                    bestTimeOfDay: .afternoon,
                    category: .focus,
                    moodTag: mood,
                    description: "Review and organize existing work"
                )
            ]
            
        case "Bored":
            return [
                TaskSuggestionModel(
                    title: "Creative Project",
                    priority: .medium,
                    estimatedDuration: 1800,
                    energyRequired: 3,
                    bestTimeOfDay: .morning,
                    category: .creative,
                    moodTag: mood,
                    description: "Start something new and engaging"
                ),
                TaskSuggestionModel(
                    title: "Learn Something",
                    priority: .medium,
                    estimatedDuration: 1500,
                    energyRequired: 3,
                    bestTimeOfDay: .afternoon,
                    category: .focus,
                    moodTag: mood,
                    description: "Explore a new skill or topic"
                )
            ]
            
        case "Sad":
            return [
                TaskSuggestionModel(
                    title: "Gentle Tasks",
                    priority: .low,
                    estimatedDuration: 900,
                    energyRequired: 2,
                    bestTimeOfDay: .morning,
                    category: .maintenance,
                    moodTag: mood,
                    description: "Start with something small and achievable"
                ),
                TaskSuggestionModel(
                    title: "Connect",
                    priority: .medium,
                    estimatedDuration: 1200,
                    energyRequired: 2,
                    bestTimeOfDay: .afternoon,
                    category: .social,
                    moodTag: mood,
                    description: "Reach out to someone supportive"
                )
            ]
            
        default:
            return []
        }
    }
}
