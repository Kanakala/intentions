import SwiftUI
import UIKit

struct IntentionsFilterView: View {
    @Binding var filterState: IntentionsFilterState
    let goalCount: Int
    let filteredCount: Int
    var isSearchFocused: FocusState<Bool>.Binding
    
    var body: some View {
        VStack(spacing: 0) {
            // Only show searchSection when filter panel is not open
            if !filterState.showFilterPanel {
                searchSection
            }
            // Filter Panel (collapsible)
            if filterState.showFilterPanel {
                filterPanel
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: filterState.showFilterPanel)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
    
    private var searchSection: some View {
        VStack(spacing: 12) {
            // Search Bar and Filter Toggle
            HStack(spacing: 12) {
                // Search TextField
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search intentions...", text: $filterState.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .focused(isSearchFocused)
                    
                    if !filterState.searchText.isEmpty {
                        Button(action: {
                            filterState.searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // Filter Toggle Button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        filterState.showFilterPanel.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: filterState.showFilterPanel ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                        Text("Filter")
                            .font(.caption)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(filterState.showFilterPanel ? Color.blue : Color(.systemGray6))
                    .foregroundColor(filterState.showFilterPanel ? .white : .primary)
                    .cornerRadius(10)
                }
            }
            
            // Results Count
            HStack {
                Text("\(filteredCount) of \(goalCount) intentions")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var filterPanel: some View {
        VStack(spacing: 16) {
            Divider()
            
            // Sort Options
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundColor(.blue)
                    Text("Sort By")
                        .font(.headline)
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    ForEach(GoalSortOption.allCases) { sortOption in
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            filterState.sortOption = sortOption
                            withAnimation(.easeInOut(duration: 0.3)) {
                                filterState.showFilterPanel = false
                            }
                        }) {
                            HStack {
                                Image(systemName: sortOption.systemImage)
                                    .font(.caption)
                                Text(sortOption.rawValue)
                                    .font(.caption)
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(filterState.sortOption == sortOption ? Color.blue.opacity(0.2) : Color(.systemGray6))
                            .foregroundColor(filterState.sortOption == sortOption ? .blue : .primary)
                            .cornerRadius(6)
                        }
                    }
                }
            }
            
            // Filter Options
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease")
                        .foregroundColor(.green)
                    Text("Filter By")
                        .font(.headline)
                    Spacer()
                }
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    ForEach(GoalFilterOption.allCases) { filterOption in
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            filterState.filterOption = filterOption
                            withAnimation(.easeInOut(duration: 0.3)) {
                                filterState.showFilterPanel = false
                            }
                        }) {
                            HStack {
                                Image(systemName: filterOption.systemImage)
                                    .font(.caption)
                                Text(filterOption.rawValue)
                                    .font(.caption)
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(filterState.filterOption == filterOption ? Color.green.opacity(0.2) : Color(.systemGray6))
                            .foregroundColor(filterState.filterOption == filterOption ? .green : .primary)
                            .cornerRadius(6)
                        }
                    }
                }
            }
            
            // Reset Button
            Button(action: {
                withAnimation {
                    filterState = IntentionsFilterState()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Reset All Filters")
                }
                .font(.caption)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .foregroundColor(.primary)
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
}

// Compact version for smaller spaces
struct CompactIntentionsFilterView: View {
    @Binding var filterState: IntentionsFilterState
    let goalCount: Int
    let filteredCount: Int
    
    var body: some View {
        HStack(spacing: 8) {
            // Search TextField
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.caption)
                TextField("Search...", text: $filterState.searchText)
                    .font(.caption)
                
                if !filterState.searchText.isEmpty {
                    Button(action: {
                        filterState.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Sort Picker
            Menu {
                ForEach(GoalSortOption.allCases) { sortOption in
                    Button(action: {
                        filterState.sortOption = sortOption
                    }) {
                        Label(sortOption.rawValue, systemImage: sortOption.systemImage)
                    }
                }
            } label: {
                Image(systemName: filterState.sortOption.systemImage)
                    .foregroundColor(.blue)
                    .font(.caption)
                    .padding(6)
            }
            
            // Filter Picker
            Menu {
                ForEach(GoalFilterOption.allCases) { filterOption in
                    Button(action: {
                        filterState.filterOption = filterOption
                    }) {
                        Label(filterOption.rawValue, systemImage: filterOption.systemImage)
                    }
                }
            } label: {
                Image(systemName: filterState.filterOption.systemImage)
                    .foregroundColor(.green)
                    .font(.caption)
                    .padding(6)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

#Preview("Full Filter View") {
    @Previewable @State var filterState = IntentionsFilterState()
    @Previewable @FocusState var isSearchFocused: Bool
    
    return ScrollView {
        IntentionsFilterView(
            filterState: $filterState,
            goalCount: 10,
            filteredCount: 7,
            isSearchFocused: $isSearchFocused
        )
        .padding()
    }
}

#Preview("Compact Filter View") {
    @Previewable @State var filterState = IntentionsFilterState()
    
    return VStack {
        CompactIntentionsFilterView(
            filterState: $filterState,
            goalCount: 10,
            filteredCount: 7
        )
        .background(Color(.systemBackground))
        Spacer()
    }
} 