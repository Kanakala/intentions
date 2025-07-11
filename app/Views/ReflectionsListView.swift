import SwiftUI

struct ReflectionsListView: View {
    let goal: Goal
    @ObservedObject var dataStore: DataStore
    @State private var showingNewReflection = false
    
    var reflections: [DailyReflection] {
        dataStore.getReflectionsForGoal(goal.id)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(reflections) { reflection in
                    NavigationLink(destination: ReflectionDetailView(reflection: reflection, goal: goal)) {
                        ReflectionRowView(reflection: reflection)
                    }
                }
            }
            .navigationTitle("Your Journey")
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
            .sheet(isPresented: $showingNewReflection) {
                DailyReflectionView(goal: goal, onDismiss: {
                    showingNewReflection = false
                })
            }
        }
        .onAppear {
            // View appeared
        }
    }
}

struct ReflectionRowView: View {
    let reflection: DailyReflection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(reflection.date.formatted(date: .long, time: .shortened))
                .font(.headline)
            
            if let mood = reflection.mood {
                HStack {
                    Text(mood.emoji)
                    Text(mood.rawValue)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("\(reflection.responses.count) responses")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
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