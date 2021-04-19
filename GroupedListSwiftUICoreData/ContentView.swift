//
//  ContentView.swift
//  GroupedListSwiftUICoreData
//
//  Created by Gene Bogdanovich on 16.04.21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: TodoSection.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \TodoSection.date, ascending: false)
    ]) private var sections: FetchedResults<TodoSection>
    @State private var date = Date()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        
        return formatter
    }()
    
    var body: some View {
        VStack {
            List {
                ForEach(sections, id: \.name) { section in
                    Section(header: Text(section.name!)) {
                        ForEach(section.todosArrayProxy) { todo in
                            HStack {
                                Text(todo.title!)
                                Text("\(todo.date!, formatter: dateFormatter)")
                            }
                        }
                        .onDelete { offsets in
                            offsets.forEach { (index) in
                                let todo = section.todosArrayProxy[index]
                                
                                // If deleting the last todo in section, clean up that section.
                                if (section.todosArrayProxy.count == 1) {
                                    moc.delete(section)
                                }
                                moc.delete(todo)
                            }
                        }
                    }
                }
            }
            
            Form {
                DatePicker(selection: $date, in: ...Date(), displayedComponents: .date) {
                    Text("Date")
                }
            }
            
            Button(action: {
                let newTodo = Todo(context: moc)
                newTodo.title = String(Int.random(in: 0 ..< 100))
                newTodo.date = date
                newTodo.id = UUID()
                
                // Use Find or Create pattern for TodoSection.
                let sectionName = dateFormatter.string(from: date)
                let sectionFetch: NSFetchRequest<TodoSection> = TodoSection.fetchRequest()
                sectionFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(TodoSection.name), sectionName)
                
                let results = try! moc.fetch(sectionFetch)
                
                if results.isEmpty {
                    // Section not found, create new section.
                    let newSection = TodoSection(context: moc)
                    newSection.name = sectionName
                    newSection.date = date
                    newSection.addToTodos(newTodo)
                } else {
                    // Section found, use it.
                    let existingSection = results.first!
                    existingSection.addToTodos(newTodo)
                }
                
                try! moc.save()
            }, label: {
                Text("Add new todo")
            })
        }
    }
}

extension TodoSection {
    var todosArrayProxy: [Todo] {
        (todos as? Set<Todo> ?? []).sorted()
    }
}

extension Todo: Comparable {
    public static func < (lhs: Todo, rhs: Todo) -> Bool {
        lhs.title! < rhs.title!
    }
}
