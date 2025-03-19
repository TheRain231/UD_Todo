//
//  AuthViewModel.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 19.03.2025.
//


import SwiftUI

@Observable
final class AuthViewModel {
    var username: String = ""
    var password: String = ""
    var isAuthenticated: Bool = false
    var errorMessage: String?
    
    private let baseURL = "http://localhost:8000"

    // MARK: - Вход (Sign In)
    func signIn() {
        guard let url = URL(string: "\(baseURL)/auth/sign-in") else { return }
        let credentials = ["username": username, "password": password]
        sendRequest(to: url, with: credentials) { success in
            DispatchQueue.main.async {
                self.isAuthenticated = success
                self.errorMessage = success ? nil : "Ошибка входа"
            }
        }
    }

    // MARK: - Регистрация (Sign Up)
    func signUp() {
        guard let url = URL(string: "\(baseURL)/auth/sign-up") else { return }
        let user = ["username": username, "password": password, "name": username]
        sendRequest(to: url, with: user) { success in
            DispatchQueue.main.async {
                self.isAuthenticated = success
                self.errorMessage = success ? nil : "Ошибка регистрации"
            }
        }
    }

    // MARK: - Отправка запроса
    private func sendRequest(to url: URL, with body: [String: String], completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            completion(true) // Можно обработать ответ сервера
        }.resume()
    }
}
