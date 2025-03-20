//
//  AuthViewModel.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 19.03.2025.
//


import SwiftUI

@Observable
final class AuthViewModel {
    var name: String = ""
    var username: String = ""
    var password: String = ""
    var errorMessage: String?
}
