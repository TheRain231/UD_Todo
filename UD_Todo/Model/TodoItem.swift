//
//  TodoItem.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

struct TodoItem: Codable {
    var id: Int
    var title: String
    var description: String
    var done: Bool
    
    mutating func toggleDone() {
        done.toggle()
        AuthManager.shared.putItemById(itemId: id, itemTitle: title, itemDescription: description, itemDone: done) { result in
            switch result {
            case .success(_):
                print("item changed")
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
}

var todoItems = [TodoItem(id: 0, title: "Task1", description: "task1", done: false),
                 TodoItem(id: 1, title: "Task2", description: "task2", done: false),
                 TodoItem(id: 2, title: "Task3", description: "task3", done: true)]
