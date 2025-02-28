//
//  User.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

final class User {
    static var shared = User(name: "user", password: "1234", username: "username")
    
    var name: String = ""
    var password: String = ""
    var username: String = ""
    
    init(name: String, password: String, username: String) {
        self.name = name
        self.password = password
        self.username = username
    }
}
