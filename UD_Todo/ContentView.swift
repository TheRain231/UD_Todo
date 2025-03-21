//
//  ContentView.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

import SwiftUI

struct ContentView: View {
    @State var isAuthenticated = false

    var body: some View {
        Group {
            if isAuthenticated {
                MainView()
            } else {
                NavigationStack {
                    LoginView()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .login, object: nil)) { _ in
            isAuthenticated = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .logout, object: nil)) { _ in
            isAuthenticated = false
        }
    }
}

extension Notification.Name {
    static let login = Notification.Name("login")
    static let logout = Notification.Name("logout")
}

#Preview {
    ContentView()
}
