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
            
            TextField("Имя", text: $viewModel.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
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
                AuthManager.shared.signUp(name: viewModel.name,
                                   username: viewModel.username,
                                   password: viewModel.password) { result in
                    switch result {
                    case .success(_):
                        AuthManager.shared.signIn(username: viewModel.username,
                                           password: viewModel.password, completion: { res in
                            switch res {
                            case .success(_):
                                return
                            case .failure(let failure):
                                viewModel.errorMessage = failure.localizedDescription
                            }
                        })
                    case .failure(let failure):
                        viewModel.errorMessage = failure.localizedDescription
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Уже есть аккаунт? Войти") {
                navigateToLogin = true
            }
            .foregroundColor(.blue)
        }
        .padding()
        .navigationDestination(isPresented: $navigateToLogin) {
            LoginView()
                .navigationBarBackButtonHidden()
        }
    }
}
