//
//  TodoList.swift
//  SimpleTodo
//
//  Created by Ben Scheirman on 7/29/22.
//

import SwiftUI

struct TodoList: View {
    @Binding var todos: [Todo]
    @FocusState var focusedTodoID: UUID?

//    @State var editMode: EditMode = .active

    var body: some View {
        ZStack {
            List {
                ForEach($todos) { $todo in
                    TodoRow(todo: .init(get: {
                        todo
                    }, set: { mutatedTodo in
                        let isToggleChange = mutatedTodo.isCompleted != todo.isCompleted
                        $todo.wrappedValue = mutatedTodo
                        if isToggleChange {
                            print("Toggled!")
                            handleToggleChange(todo)
                        }
                    }))
                        .listRowSeparator(.hidden)
                        .focused($focusedTodoID, equals: todo.id)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive, action: {
                                withAnimation {
                                    guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
                                    todos.remove(at: index)
                                }
                            }) {
                                Label("Delete Todo", systemImage: "trash")
                            }
                        }
                }
                .onMove(perform: move)            }
//            .environment(\.editMode, $editMode)
            .scrollDismissesKeyboard(.immediately)
            .listStyle(.plain)

            Button(action: {
                let newTodo = Todo("")
                withAnimation {
                    todos.insert(newTodo, at: 0)
                    focusedTodoID = newTodo.id
                }
            }) {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .bold()
                    .padding()
                    .background(
                        Circle().fill(Color.accentColor)
                    )
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom)
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        todos.move(fromOffsets: source, toOffset: destination)
        todos.indices.forEach {
            todos[$0].sortOrder = $0
        }
        todos = todos.sorted()
    }

    private func handleToggleChange(_ todo: Todo) {
        guard let originalIndex = todos.firstIndex(where: { $0.id == todo.id }) else {
            return
        }

        for index in todos.indices.reversed() where index != originalIndex {
            if todos[index].isCompleted {
                continue
            }
            withAnimation {
                move(from: .init(integer: originalIndex), to: index + 1)
            }
            break
        }
    }
}


struct TodoList_Previews: PreviewProvider {
    struct DemoView: View {
        @State var todos = [Todo].sample
        var body: some View {
            TodoList(todos: $todos)
        }
    }
    static var previews: some View {
        DemoView()
    }
}
