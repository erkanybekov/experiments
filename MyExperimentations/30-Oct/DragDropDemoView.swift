//
//  TaskItem.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 10/30/25.
//


import SwiftUI
import Combine
import UniformTypeIdentifiers

// MARK: - Шаг 1: Модель данных
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

// Регистрируем собственный UTType для нашего типа данных
//extension UTType {
//    static let taskItem = UTType(exportedAs: "com.app.taskitem")
//}

// MARK: - Шаг 2: ViewModel с бизнес-логикой

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

// MARK: - Шаг 3: View с drag & drop

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

// MARK: - Шаг 4: Компонент списка задач

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

// MARK: - Шаг 5: Компонент строки задачи

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

// MARK: - Preview

#Preview {
    DragDropView()
}

/*
 ПОШАГОВОЕ ОБЪЯСНЕНИЕ РАБОТЫ:
 
 1. ПОДГОТОВКА (Шаг 1-2):
    - Создаем модель TaskItem с протоколом Transferable
    - Регистрируем UTType для передачи данных
    - Создаем ViewModel с двумя массивами
 
 2. DRAG (Начало перетаскивания):
    - Пользователь зажимает элемент
    - .draggable(task) создает данные для переноса
    - Система создает preview элемента
 
 3. HOVER (Перемещение):
    - Когда элемент над drop-зоной, срабатывает isTargeted
    - Меняется цвет фона (визуальная обратная связь)
 
 4. DROP (Отпускание):
    - .dropDestination принимает данные
    - handleDrop получает массив droppedTasks
    - viewModel.moveTask() перемещает задачу:
      a) Удаляет из обоих массивов
      b) Добавляет в целевой массив
    - withAnimation делает переход плавным
 
 5. UPDATE (Обновление UI):
    - @Published свойства обновляются
    - SwiftUI автоматически перерисовывает интерфейс
    - Задача появляется в новом списке
 */
