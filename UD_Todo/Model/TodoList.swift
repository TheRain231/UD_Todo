//
//  TodoList.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

struct TodoList: Identifiable {
    var description: String
    var id: Int
    var title: String
    
    var todoItems: [TodoItem] = []
}

var mockTodoLists: [TodoList] = [
    .init(description: "list1", id: 0, title: "List1", todoItems: [.init(id: 0, title: "Task1", description: "task1", done: false),
                                                                   .init(id: 1, title: "Task2", description: "task2", done: false),
                                                                   .init(id: 2, title: "Task3", description: "task3", done: true)]),
    .init(description: "list2", id: 1, title: "List2"),
    .init(description: "list3", id: 2, title: "List3"),
    .init(description: "list4", id: 3, title: "List4")
]
