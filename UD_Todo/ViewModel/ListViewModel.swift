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
    var todoItems: [TodoItem]
    
    var isAddingSheetPresented = false
    var addingTitle = ""
    var addingDescription = ""
    
    var isDetailSheetPresented = false
    var selectedItemId: Int? = nil
    
    init(todoList: TodoList = TodoList(id: 0, title: "didn't load", description: "nothing here"), allItems: [TodoItem]) {
        self.todoList = todoList
        self.todoItems = allItems.filter { $0.master_id == todoList.id }
    }

    func toggleItemDone(at index: Int) {
        todoItems[index].toggleDone()
    }

    func removeItems(at offsets: IndexSet) {
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
    }
    
    func onItemClicked(_ id: Int) {
        selectedItemId = id
        isDetailSheetPresented = true
    }
    
    func closeDetailSheet() {
        isDetailSheetPresented = false
    }
}
