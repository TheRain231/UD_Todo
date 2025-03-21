//
//  ListViewModel.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

import SwiftUI

@Observable
final class ListViewModel {
    var todoList: TodoList
    var todoItems: [TodoItem] = []
    
    var isAddingSheetPresented = false
    var addingTitle = ""
    var addingDescription = ""
    
    var isDetailSheetPresented = false
    var selectedItemId: Int? = nil
    
    init(todoList: TodoList = TodoList(id: 0, title: "loading", description: "nothing here")) {
        self.todoList = todoList
    }
    
    func fetchList(_ todoList: TodoList) {
        self.todoList = todoList
        
        AuthManager.shared.getItemsForList(listId: todoList.id, completion: { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedItems):
                    self.todoItems = fetchedItems
                case .failure(let error):
                    print("Ошибка загрузки: \(error.localizedDescription)")
                }
            }
        })
    }

    func toggleItemDone(at index: Int) {
        todoItems[index].toggleDone()
    }

    func removeItems(at offsets: IndexSet) {
        let itemsToRemove = offsets.map { todoItems[$0] } // Сохраняем удаляемые элементы
        
        for item in itemsToRemove {
            AuthManager.shared.deleteItemById(itemId: item.id) { result in
                switch result {
                case .success:
                    print("Элемент \(item.id) успешно удален")
                case .failure(let error):
                    print("Ошибка удаления элемента \(item.id): \(error.localizedDescription)")
                }
            }
        }
        todoItems.remove(atOffsets: offsets)
    }
    
    func onAddButtonClicked() {
        isAddingSheetPresented = true
    }
    
    func closeAddingSheet() {
        isAddingSheetPresented = false
    }
    
    func saveAddingSheet() {
        isAddingSheetPresented = false
        AuthManager.shared.addItemToList(listId: todoList.id, itemTitle: addingTitle, itemDescription: addingDescription) { result in
            switch result {
            case .success(let id):
                AuthManager.shared.getItemById(itemId: id){ result in
                    switch result {
                    case .success(let success):
                        self.todoItems.append(success)
                        print("list added")
                    case .failure(let failure):
                        print(failure.localizedDescription);
                    }
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func onItemClicked(_ id: Int) {
        selectedItemId = id
        isDetailSheetPresented = true
    }
    
    func closeDetailSheet() {
        isDetailSheetPresented = false
    }
}
