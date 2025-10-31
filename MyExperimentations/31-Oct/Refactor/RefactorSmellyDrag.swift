////
////  Item.swift
////  MyExperimentations
////
////  Created by Erlan Kanybekov on 10/31/25.
////
//
//
//import SwiftUI
//import Combine
//import UniformTypeIdentifiers
//
//
//// MARK: Model ✅
//struct Item: Identifiable, Codable, Equatable, Transferable {
//    static var transferRepresentation: some TransferRepresentation {
//        CodableRepresentation(contentType: .json)
//    }
//    
//    let id: UUID
//    var name: String
//    
//    init(id: UUID = UUID(), name: String) {
//        self.id = id
//        self.name = name
//    }
//}
//
//// MARK: ViewModel ✅
//class BadViewModel: ObservableObject {
//    @Published var availableTasks: [Item]
//    @Published var selectedTasks: [Item]
//    
//    init() {
//        self.availableTasks = [
//            Item(name: "Task 1"),
//            Item(name: "Task 2"),
//            Item(name: "Task 3"),
//            Item(name: "Task 4"),
//            Item(name: "Task 5")
//        ]
//        self.selectedTasks = []
//    }
//    
//    // split into move and reorder
//    func move(_ task: Item, from source: [Item], to destination: inout [Item], at index: Int?) {
//        // remove from available
//        if availableTasks.contains(where: { $0.id == task.id }) {
//            availableTasks.removeAll(where: { $0.id == task.id })
//        } else {
//            selectedTasks.removeAll(where: { $0.id == task.id })
//        }
//        
//        // insert to desination
//        if let index = index {
//            destination.insert(task, at: min(index, destination.count))
//        } else {
//            destination.append(task)
//            
//        }
//    }
//    
//    func reorder(in list: inout [Item], from: IndexSet, to: Int) {
//        list.move(fromOffsets: from, toOffset: to)
//    }
//}
//
//// MARK: BadDragDropView -> Split into Row and Colum Views
//
//struct CardColumn: View {
//    let title: String
//    @Binding var items: [Item]
//    @ObservedObject var vm: BadViewModel
//    @State private var isTargeted = false
//    
//    var body: some View {
//        VStack {
//            // title
//            Title
//            // ScrollView
//            taskList
//            //footer
//            footer
//        }
//    }
//    
//    private var Title: some View {
//        Text(title)
//            .font(.headline)
//            .foregroundColor(.secondary)
//    }
//    
//    private var taskList: some View {
//        ScrollView {
//            LazyVStack {
//                ForEach(items, id: \.id) { task in
//                    CardRow(item: task)
//                        .draggable(task)
//                        .dropDestination(for: Item.self) { droppedTasks, _ in
//                            handleDrop(droppedTasks, on: task)
//                        }
//                }
//            }
//            .padding(.vertical, items.isEmpty ? 40: 8)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        // dropArea
//        .background(dropArea)
//        // dropDestination
//        .dropDestination(for: Item.self) {  droppedTasks, _ in
//            handleDrop(droppedTasks, on: nil)
//        } isTargeted: { targeted in
//            isTargeted = targeted
//        }
//    }
//    
//    private var dropArea: some View {
//        RoundedRectangle(cornerRadius: 12)
//            .fill(isTargeted ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .strokeBorder(isTargeted ? Color.blue : Color.clear, lineWidth: 2)
//            )
//    }
//    
//    private var footer: some View {
//        Text("\(items.count) tasks")
//            .font(.headline)
//            .foregroundColor(.secondary)
//    }
//    
//    private func handleDrop(_ droppedTasks: [Item], on targetTask: Item?) -> Bool {
//        guard let droppedTask = droppedTasks.first else { return false }
//        
//        let targetIndex = targetTask.flatMap { target in
//            items.firstIndex(where: { $0.id == target.id })
//        }
//        
//        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//            vm.move(
//                droppedTask,
//                from: items,
//                to: &items,
//                at: targetIndex
//            )
//        }
//        
//        return true
//    }}
//
//struct CardRow: View {
//    let item: Item
//    
//    var body: some View {
//        HStack {
//            Text(item.name)
//                .font(.body)
//            
//            Spacer()
//            
//            Image(systemName: "line.3.horizontal")
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color(uiColor: .systemBackground))
//                .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
//        )
//        .padding(.horizontal, 8)
//    }
//}
//
//struct BadDragDropView: View {
//    @StateObject private var badViewModel = BadViewModel()
//    
//    var body: some View {
//        NavigationStack {
//            HStack {
//                //CardColumn
//                CardColumn(title: "Available items", items: $badViewModel.availableTasks, vm: badViewModel)
//                Divider()
//                // CardColumn
//                CardColumn(title: "Selected items", items: $badViewModel.selectedTasks, vm: badViewModel)
//            }
//            .padding()
//            .navigationTitle("Drag & Drop")
//        }
//    }
//}
//
//#Preview {
//    BadDragDropView()
//}
