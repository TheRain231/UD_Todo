//
//  TodoItem.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

struct TodoItem {
    var id: Int
    var title: String
    var description: String
    var done: Bool
    
    mutating func toggleDone() {
        done.toggle()
    }
}
