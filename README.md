# SwiftUI Drag & Drop Example

A **step-by-step guide** for implementing a drag & drop Task Manager in SwiftUI with all necessary code included.

---

## Features

- Drag & drop tasks between **Available** and **Selected** lists.
- Reorder tasks within a list.
- Visual hover feedback.
- Smooth animations with `withAnimation`.
- Clean SwiftUI + Combine architecture.

---

## Step 1: Model

```swift
import SwiftUI
import UniformTypeIdentifiers

struct TaskItem: Identifiable, Codable, Equatable, Transferable {
    let id: UUID
    var title: String

    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .json)
    }
}
```

## Step 2: ViewModel

```swift
import Combine

@MainActor
final class DragDropViewModel: ObservableObject {
    @Published var availableTasks: [TaskItem]
    @Published var selectedTasks: [TaskItem]

    init() {
        self.availableTasks = [
            TaskItem(title: "Task 1"),
            TaskItem(title: "Task 2"),
            TaskItem(title: "Task 3"),
            TaskItem(title: "Task 4"),
            TaskItem(title: "Task 5")
        ]
        self.selectedTasks = []
    }

    func moveTask(_ task: TaskItem, from source: [TaskItem], to destination: inout [TaskItem], at index: Int?) {
        if availableTasks.contains(where: { $0.id == task.id }) {
            availableTasks.removeAll { $0.id == task.id }
        } else {
            selectedTasks.removeAll { $0.id == task.id }
        }

        if let index = index {
            destination.insert(task, at: min(index, destination.count))
        } else {
            destination.append(task)
        }
    }

    func reorderTasks(in list: inout [TaskItem], from: IndexSet, to: Int) {
        list.move(fromOffsets: from, toOffset: to)
    }
}
```

## Step 3: TaskRow View

```swift
import SwiftUI

struct TaskRow: View {
    let task: TaskItem

    var body: some View {
        HStack(spacing: 12) {
            Text(task.title)
                .font(.body)
            Spacer()
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
        )
    }
}
```

## Step 4: TaskColumn View

```swift
import SwiftUI

struct TaskColumn: View {
    let title: String
    @Binding var tasks: [TaskItem]
    @ObservedObject var viewModel: DragDropViewModel
    
    @State private var isTargeted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            taskListView
            footerView
        }
    }
    
    private var headerView: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.secondary)
    }
    
    private var taskListView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(tasks) { task in
                    TaskRow(task: task)
                        .draggable(task)
                        .dropDestination(for: TaskItem.self) { droppedTasks, _ in
                            handleDrop(droppedTasks, on: task)
                        }
                }
            }
            .padding(.vertical, tasks.isEmpty ? 40 : 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(dropAreaBackground)
        .dropDestination(for: TaskItem.self) { droppedTasks, _ in
            handleDrop(droppedTasks, on: nil)
        } isTargeted: { targeted in
            isTargeted = targeted
        }
    }
    
    private var dropAreaBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isTargeted ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isTargeted ? Color.blue : Color.clear, lineWidth: 2)
            )
    }
    
    private var footerView: some View {
        Text("\(tasks.count) tasks")
            .font(.caption)
            .foregroundColor(.secondary)
    }

     private func handleDrop(_ droppedTasks: [Item], on targetTask: Item?) -> Bool {
        guard let droppedTask = droppedTasks.first else { return false }
        
        let targetIndex = targetTask.flatMap { target in
            items.firstIndex(where: { $0.id == target.id })
        }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            vm.move(
                droppedTask,
                from: items,
                to: &items,
                at: targetIndex
            )
        }
        
        return true
    }}
}
```

## Step 5: DragDropView

```swift
import SwiftUI

struct DragDropView: View {
    @StateObject private var viewModel = DragDropViewModel()

    var body: some View {
        NavigationView {
            HStack(spacing: 20) {
                TaskColumn(title: "Available", tasks: $viewModel.availableTasks, viewModel: viewModel)
                Divider()
                TaskColumn(title: "Selected", tasks: $viewModel.selectedTasks, viewModel: viewModel)
            }
            .padding()
            .navigationTitle("Drag & Drop")
        }
    }
}

#Preview {
    DragDropView()
}
```

## Summary

1. Define `TaskItem` model.
2. Create `DragDropViewModel`.
3. Build `TaskRow`.
4. Build `TaskColumn` with drag & drop.
5. Assemble in `DragDropView`.
6. Run and test dragging tasks between Available and Selected lists.

**Notes:**
- Works on iOS 17+.
- Extendable for multiple columns or multi-item drag.
- Smooth animations and hover feedback included.

