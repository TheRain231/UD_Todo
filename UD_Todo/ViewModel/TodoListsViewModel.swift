//
//  TodoListsViewModel.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

import SwiftUI

@Observable
final class TodoListsViewModel {
    var todoLists: [TodoList] = mockTodoLists
    
    var searchText: String = ""
}

