//
//  LoginView.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 19.03.2025.
//


import SwiftUI

struct LoginView: View {
    @State var viewModel = AuthViewModel()
    @State private var navigateToRegister = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Вход")
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
            
            Button("Войти") {
                viewModel.signIn()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Нет аккаунта? Зарегистрироваться") {
                navigateToRegister = true
            }
            .foregroundColor(.blue)
            
            if viewModel.isAuthenticated {
                Text("Вы успешно вошли!")
                    .foregroundColor(.green)
                    .font(.headline)
            }
        }
        .padding()
        .navigationDestination(isPresented: $navigateToRegister) {
            RegisterView()
        }
    }
}
