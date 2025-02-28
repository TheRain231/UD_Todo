//
//  ContentView.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TodoListsView()
                .tabItem {
                    Label("Задачи", systemImage: "list.bullet")
                }
            
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
