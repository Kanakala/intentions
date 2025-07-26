//
//  ContentView.swift
//  app
//
//  Created by Sumanth Kanakala on 30/03/25.
//

import SwiftUI

struct MainView: View {
    @StateObject private var dataStore = DataStore()
    
    var body: some View {
        MainTabView(dataStore: dataStore)
            .environmentObject(dataStore)
    }
}

#Preview {
    MainView()
}
