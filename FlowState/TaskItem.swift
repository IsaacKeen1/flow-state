// TaskItem.swift
import SwiftUI

struct TaskItem: Identifiable, Codable {
    var id: UUID  // Changed from 'let id = UUID()' to 'var id: UUID'
    var title: String
    var isCompleted: Bool
    var priority: Priority
    var dueDate: Date?
    var mood: String?
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool, priority: Priority, dueDate: Date? = nil, mood: String? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.mood = mood
    }
    
    enum Priority: String, Codable, CaseIterable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .blue
            }
        }
    }
}
