import SwiftUI

enum TaskFilter {
    case all, today, upcoming, completed

    var title: String {
        switch self {
        case .all: return "All"
        case .today: return "Today"
        case .upcoming: return "Upcoming"
        case .completed: return "Completed"
        }
    }
}

struct FilterButton: View {
    let filter: TaskFilter
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(filter.title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.clear)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
