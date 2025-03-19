//
//  TodoItem.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

struct TodoItem {
    var id: Int
    var master_id: Int
    var title: String
    var description: String
    var done: Bool
    
    mutating func toggleDone() {
        done.toggle()
    }
}

var todoItems = [TodoItem(id: 0, master_id: 0, title: "Task1", description: "task1", done: false),
                 TodoItem(id: 1, master_id: 0, title: "Task2", description: "task2", done: false),
                 TodoItem(id: 2, master_id: 0, title: "Task3", description: "task3", done: true)]
