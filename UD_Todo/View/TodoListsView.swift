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
                    ForEach(vm.todoLists, id: \.id) { todoList in
                        NavigationLink(destination: ListView(todoList: todoList)) {
                            ListCellView(todoList: todoList)
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            vm.onAddButtonClicked()
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
                .sheet(isPresented: $vm.isAddingSheetPresented) {
                    addingSheet
                }
                .searchable(text: $vm.searchText, prompt: "Поиск")
                .onAppear {
                    vm.fetchLists()
                }
            }
            .navigationTitle("Задачи")
        }
    }
    
    var addingSheet: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Title", text: $vm.addingTitle, prompt: Text("Название"))
                    TextField("Description", text: $vm.addingDescription, prompt: Text("Описание"))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Добавить список")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Закрыть") {
                        vm.closeAddingSheet()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Сохранить") {
                        vm.saveAddingSheet()
                    }
                }
            }
        }
        .onDisappear {
            vm.closeAddingSheet()
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
