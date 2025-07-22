import SwiftUI

/// ReflectionsListView - Fixed to remove problematic scroll optimizations
/// PERFORMANCE OPTIMIZATIONS KEPT:
/// - Cached reflection lookups from DataStore
/// - Efficient date formatting
/// 
/// REVERTED (PROBLEMATIC):
/// - LazyVStack replaced back with List for proper navigation
/// - Removed scroll state tracking that caused visual glitches
/// - Removed dynamic complexity that broke user experience
struct ReflectionsListView: View {
    let goal: Goal
    @ObservedObject var dataStore: DataStore
    @State private var showingNewReflection = false
    
    var reflections: [DailyReflection] {
        dataStore.getReflectionsForGoal(goal.id)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // FIXED: Back to List for proper navigation and performance
                List {
                    ForEach(reflections) { reflection in
                        NavigationLink(destination: ReflectionDetailView(reflection: reflection, goal: goal)) {
                            ReflectionRowView(reflection: reflection)
                        }
                    }
                }
                .listStyle(.plain)
                .background(Color(.systemGroupedBackground))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingNewReflection = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .navigationTitle("Your Journey")
            .sheet(isPresented: $showingNewReflection) {
                DailyReflectionView(goal: goal, onDismiss: {
                    showingNewReflection = false
                })
            }
        }
    }
}

// MARK: - SIMPLIFIED: ReflectionRowView without problematic scroll optimizations
struct ReflectionRowView: View {
    let reflection: DailyReflection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatDate(reflection.date))
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text(formatTime(reflection.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let mood = reflection.mood {
                    VStack(spacing: 2) {
                        Text(mood.emoji)
                            .font(.title2)
                        
                        Text(mood.rawValue)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            HStack {
                Text("\(reflection.responses.count) responses")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Simple Date Formatting (keeping this optimization)
    private func formatDate(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ReflectionDetailView: View {
    let reflection: DailyReflection
    let goal: Goal
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Date and Mood
                VStack(spacing: 10) {
                    Text(reflection.date.formatted(date: .long, time: .shortened))
                        .font(.headline)
                    
                    if let mood = reflection.mood {
                        HStack {
                            Text(mood.emoji)
                                .font(.title)
                            Text(mood.rawValue)
                                .font(.title2)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
                
                // Responses
                ForEach(reflection.responses) { response in
                    if let action = goal.dailyActions.first(where: { $0.id == response.actionId }) {
                        ResponseCardView(action: action, response: response)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Reflection Details")
    }
}

struct ResponseCardView: View {
    let action: DailyAction
    let response: DailyActionResponse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(action.prompt)
                .font(.headline)
            
            switch action.type {
            case .scale:
                Text("Rating: \(response.value)/10")
            case .text:
                Text(response.value)
            case .number:
                Text(response.value + (action.configuration.unit ?? ""))
            case .check:
                Text(response.value == "true" ? "Completed" : "Not Completed")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
} 