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
                    ForEach(vm.filteredTodoLists, id: \.id) { todoList in
                        NavigationLink(destination: ListView(todoList: todoList)) {
                            ListCellView(todoList: todoList)
                        }
                        .foregroundStyle(.primary)
                        .contextMenu {
                            contextButtons(todoList)
                        }
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
                .sheet(item: $vm.chosenList) {_ in 
                    editingSheet
                }
                .searchable(text: $vm.searchText, prompt: "Поиск")
                .onAppear {
                    vm.fetchLists()
                }
            }
            .navigationTitle("Списки")
        }
    }
    
    func contextButtons(_ todoList: TodoList) -> some View {
        VStack {
            Button(role: .destructive) {
                vm.deleteList(todoList)
            } label: {
                Label("Удалить", systemImage: "trash")
            }
            Button() {
                vm.chooseList(todoList)
            } label: {
                Label("Редактировать", systemImage: "pencil")
            }
        }
    }
    
    var editingSheet: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Title", text: $vm.editingTitle, prompt: Text("Название"))
                    TextField("Description", text: $vm.editingDescription, prompt: Text("Описание"))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Изменить список")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Закрыть") {
                        vm.closeEditingSheet()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Сохранить") {
                        vm.editList(vm.chosenList!)
                        vm.closeEditingSheet()
                    }
                }
            }
        }
        .onDisappear {
            vm.closeEditingSheet()
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
                .aspectRatio(2, contentMode: .fit)
            Text(todoList.title)
                .font(.title)
                .fontWeight(.black)
        }
    }
}

#Preview {
    TodoListsView()
}
