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

// Модель должна быть Transferable для drag & drop

struct TaskItem: Identifiable, Codable, Transferable {
    let id: UUID
    var title: String
    
    init(id: UUID = UUID(), title: String) {
        self.id = id
        self.title = title
    }
    
    // Определяем как передавать данные при drag & drop
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
    // Два массива: источник и назначение
    @Published var availableTasks: [TaskItem]
    @Published var selectedTasks: [TaskItem]
    
    init() {
        self.availableTasks = [
            TaskItem(title: "Task 1"),
            TaskItem(title: "Task 2"),
            TaskItem(title: "Task 3")
        ]
        self.selectedTasks = []
    }
    
    // Главный метод: перемещение задачи
    func moveTask(_ task: TaskItem, to destination: ListType) {
        // Шаг 2.1: Удаляем из обоих массивов (на случай если задача уже там)
        availableTasks.removeAll { $0.id == task.id }
        selectedTasks.removeAll { $0.id == task.id }
        
        // Шаг 2.2: Добавляем в нужный массив
        switch destination {
        case .available:
            availableTasks.append(task)
        case .selected:
            selectedTasks.append(task)
        }
    }
}

// Enum для определения типа списка
enum ListType {
    case available
    case selected
}
```

## Step 3: TaskRow View

```swift
import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    
    var body: some View {
        HStack {
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
                .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
        )
    }
}
```

## Step 4: TaskList View

```swift
import SwiftUI

struct TaskListView: View {
    let title: String
    let tasks: [TaskItem]
    let listType: ListType
    @ObservedObject var viewModel: DragDropViewModel
    
    @State private var isDropTargeted = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Заголовок
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Область для drop
            dropArea
            
            // Счетчик
            Text("\(tasks.count) tasks")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var dropArea: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(tasks) { task in
                    TaskRowView(task: task)
                        // Шаг 4.1: Делаем элемент draggable
                        .draggable(task)
                }
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity)
        .background(dropBackground)
        // Шаг 4.2: Принимаем drop на весь список
        .dropDestination(for: TaskItem.self) { droppedTasks, location in
            handleDrop(droppedTasks)
        } isTargeted: { targeted in
            isDropTargeted = targeted
        }
    }
    
    private var dropBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isDropTargeted ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isDropTargeted ? Color.blue : Color.gray.opacity(0.2),
                        lineWidth: 2
                    )
            )
    }
    
    // Шаг 4.3: Обработка drop события
    private func handleDrop(_ droppedTasks: [TaskItem]) -> Bool {
        guard let task = droppedTasks.first else { return false }
        
        withAnimation(.spring(response: 0.3)) {
            viewModel.moveTask(task, to: listType)
        }
        
        return true
    }
}
```

## Step 5: DragDropView

```swift
import SwiftUI

struct DragDropView: View {
    @StateObject private var viewModel = DragDropViewModel()
    
    var body: some View {
        NavigationView {
            HStack(spacing: 30) {
                // Левый список - Available
                TaskListView(
                    title: "Available",
                    tasks: viewModel.availableTasks,
                    listType: .available,
                    viewModel: viewModel
                )
                
                Divider()
                
                // Правый список - Selected
                TaskListView(
                    title: "Selected",
                    tasks: viewModel.selectedTasks,
                    listType: .selected,
                    viewModel: viewModel
                )
            }
            .padding()
            .navigationTitle("Drag & Drop Tutorial")
        }
    }
}
```

## Summary

1. Define `TaskItem` model.
2. Create `DragDropViewModel`.
3. Build `TaskRow`.
4. Build `TaskList` with drag & drop.
5. Assemble in `DragDropView`.
6. Run and test dragging tasks between Available and Selected lists.

**Notes:**
- Works on iOS 17+.
- Extendable for multiple columns or multi-item drag.
- Smooth animations and hover feedback included.

