////
////  Task.swift
////  MyExperimentations
////
////  Created by Erlan Kanybekov on 10/30/25.
////
//
//
//import SwiftUI
//import Combine
//
//// MARK: - Model
//struct DraggablItem: Identifiable, Equatable {
//    let id = UUID()
//    var title: String
//}
//
//// MARK: - ViewModel
//@MainActor
//final class TaskListViewModel: ObservableObject {
//    @Published var tasks: [DraggablItem] = [
//        DraggablItem(title: "Task 1"),
//        DraggablItem(title: "Task 2"),
//        DraggablItem(title: "Task 3"),
//        DraggablItem(title: "Task 4")
//    ]
//    
//    func move(from source: IndexSet, to destination: Int) {
//        tasks.move(fromOffsets: source, toOffset: destination)
//    }
//}
//
//// MARK: - View
//struct TaskListView: View {
//    @StateObject private var viewModel = TaskListViewModel()
//    
//    var body: some View {
//        NavigationStack {
//            List {
//                ForEach(viewModel.tasks) { task in
//                    Text(task.title)
//                        .padding(.vertical, 8)
//                }
//                .onMove(perform: viewModel.move)
//            }
//            .navigationTitle("Tasks")
//            .toolbar {
//                EditButton()
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    TaskListView()
//}
