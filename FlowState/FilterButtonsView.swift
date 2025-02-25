import SwiftUI
import Foundation

struct FilterButtonsView: View {
    @Binding var selectedFilter: TaskFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach([TaskFilter.all, .today, .upcoming, .completed], id: \.title) { filter in
                    FilterButton(
                        filter: filter,
                        isSelected: filter == selectedFilter
                    ) {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}
