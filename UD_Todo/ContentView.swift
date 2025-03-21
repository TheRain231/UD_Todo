//
//  ContentView.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isAuthenticated") var isAuthenticated = false
    
    init() {
        if isAuthenticated {
            AuthManager.shared.tryToken { [self] result in
                switch result {
                case .success(let success):
                    if !success {
                        self.isAuthenticated = false
                        print("token is expired")
                    }
                case .failure(_):
                    self.isAuthenticated = false
                }
            }
        }
    }

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
