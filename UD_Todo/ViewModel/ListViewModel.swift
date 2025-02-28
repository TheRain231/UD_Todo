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
    
    var isAddingSheetPresented = false
    var addingTitle = ""
    var addingDescription = ""
    
    var isDetailSheetPresented = false
    var selectedItemId: Int? = nil
    
    init(todoList: TodoList) {
        self.todoList = todoList
    }
    
    init() {
        self.todoList = TodoList(description: "nothing here", id: 0, title: "didn't load")
    }
    
    func toggleItemDone(at index: Int) {
        todoList.todoItems[index].toggleDone()
    }

    func removeItems(at offsets: IndexSet) {
        todoList.todoItems.remove(atOffsets: offsets)
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
