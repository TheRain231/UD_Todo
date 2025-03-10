//
//  TodoListsView.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

import SwiftUI

struct TodoListsView: View {
    @State var vm = TodoListsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: 100)), count: 2), spacing: 5) {
                    ForEach(vm.todoLists) { todoList in
                        NavigationLink(destination: ListView(todoList: todoList)) {
                            ListCellView(todoList: todoList)
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal)
                .searchable(text: $vm.searchText, prompt: "Поиск")
            }
            .navigationTitle("Задачи")
        }
    }
}

struct ListCellView: View {
    var todoList: TodoList
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.regularMaterial)
                .aspectRatio(contentMode: .fit)
            Text(todoList.title)
        }
    }
}

#Preview {
    TodoListsView()
}
