//
//  RegisterView.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 19.03.2025.
//


import SwiftUI

struct RegisterView: View {
    @State var viewModel = AuthViewModel()
    @State private var navigateToLogin = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Регистрация")
                .font(.largeTitle)
                .bold()
            
            TextField("Логин", text: $viewModel.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            SecureField("Пароль", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button("Зарегистрироваться") {
                viewModel.signUp()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Уже есть аккаунт? Войти") {
                navigateToLogin = true
            }
            .foregroundColor(.blue)
            
            if viewModel.isAuthenticated {
                Text("Регистрация успешна!")
                    .foregroundColor(.green)
                    .font(.headline)
            }
        }
        .padding()
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginView()
        }
    }
}
