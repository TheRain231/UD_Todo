//
//  TodoListsViewModel.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

import SwiftUI

@Observable
final class TodoListsViewModel {
    var todoLists: [TodoList] = []
    var searchText: String = ""
    
    var filteredTodoLists: [TodoList] {
        if searchText.isEmpty {
            return todoLists
        } else {
            return todoLists.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var isAddingSheetPresented = false
    var addingTitle = ""
    var addingDescription = ""

    func fetchLists() {
        AuthManager.shared.getAllLists { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedLists):
                    self.todoLists = fetchedLists
                case .failure(let error):
                    print("Ошибка загрузки: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteList(_ list: TodoList) {
        AuthManager.shared.deleteList(listId: list.id) { result in
            switch result {
            case .success(_):
                print("list has been removed")
                self.todoLists.removeAll {
                    $0.id == list.id
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func onAddButtonClicked() {
        isAddingSheetPresented = true
    }
    
    func closeAddingSheet() {
        isAddingSheetPresented = false
    }
    
    func saveAddingSheet() {
        isAddingSheetPresented = false
        AuthManager.shared.createList(title: addingTitle, description: addingDescription) { result in
            switch result {
            case .success(let id):
                AuthManager.shared.getListById(listId: id) { result in
                    switch result {
                    case .success(let success):
                        self.todoLists.append(success)
                        print("list added")
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
}

