//
//  MainView.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 20.03.2025.
//

import SwiftUI

struct MainView: View {
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
    MainView()
}
