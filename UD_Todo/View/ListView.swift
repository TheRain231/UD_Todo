//
//  ListView.swift
//  UD_Todo
//
//  Created by Андрей Степанов on 26.02.2025.
//

import SwiftUI

struct ListView: View {
    var todoList: TodoList
    @State private var vm = ListViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.todoItems.indices, id: \.self) { index in
                    HStack {
                        Button {
                            vm.toggleItemDone(at: index)
                        } label: {
                            circleImage(vm.todoItems[index].done)
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            vm.onItemClicked(index)
                        } label: {
                            Text(vm.todoItems[index].title)
                        }
                        .foregroundStyle(.primary)
                    }
                }
                .onDelete(perform: vm.removeItems)
            }
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
            .sheet(isPresented: $vm.isDetailSheetPresented) {
                detailSheet
            }
            .navigationTitle(vm.todoList.title)
        }
        .onAppear {
            vm.fetchList(todoList)
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
            .navigationTitle("Добавить задачу")
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
    
    var detailSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                Text(vm.todoItems[vm.selectedItemId!].title)
                    .font(.largeTitle)
                    .bold()
                Text(vm.todoItems[vm.selectedItemId!].description)
                
                Spacer()
                
                Button {
                    vm.toggleItemDone(at: vm.selectedItemId!)
                } label: {
                    Text("Выполнено")
                        .foregroundStyle(vm.todoItems[vm.selectedItemId!].done ? Color.black : Color.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(vm.todoItems[vm.selectedItemId!].done ? Color.gray : Color.blue)
                        }
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Закрыть") {
                        vm.closeDetailSheet()
                    }
                }
            }
            .padding()
        }
        .onDisappear {
            vm.closeDetailSheet()
        }
    }
    
    func circleImage(_ isDone: Bool) -> some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 1)
                .foregroundStyle(isDone ? Color.blue : Color.secondary)
            Circle()
                .foregroundStyle(isDone ? Color.blue : Color.clear)
                .scaleEffect(0.75)
        }
        .frame(width: 20)
        .animation(.bouncy, value: isDone)
    }
}

#Preview {
    ListView(todoList: mockTodoLists.first!)
}
