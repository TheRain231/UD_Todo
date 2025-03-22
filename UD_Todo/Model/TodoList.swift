//
//  TodoList.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

struct TodoList: Codable, Identifiable {
    let id: Int
    var title: String
    var description: String
}

var mockTodoLists: [TodoList] = [
    .init(id: 0, title: "List1", description: "list1"),
    .init(id: 1, title: "List2", description: "list2"),
    .init(id: 2, title: "List3", description: "list3"),
    .init(id: 3, title: "List4", description: "list4")
]
