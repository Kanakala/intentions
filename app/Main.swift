//
//  ContentView.swift
//  app
//
//  Created by Sumanth Kanakala on 30/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var currentStep = 0
    @State private var intention = ""
    @State private var selectedOptions: Set<GoalOption> = []
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                switch currentStep {
                case 0:
                    IntentionView(intention: $intention, currentStep: $currentStep)
                case 1:
                    OptionsView(selectedOptions: $selectedOptions, currentStep: $currentStep)
                case 2:
                    SummaryView(intention: intention, selectedOptions: selectedOptions, currentStep: $currentStep)
                default:
                    EmptyView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
