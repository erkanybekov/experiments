////
////  DraggableItem.swift
////  MyExperimentations
////
////  Created by Erlan Kanybekov on 10/30/25.
////
//
//
//import SwiftUI
//import Combine
//internal import UniformTypeIdentifiers
//
//
//// MARK: - Model
//struct DraggableItem: Identifiable, Codable, Equatable, Transferable {
//    let id: UUID
//    var title: String
//    var color: Color
//    
//    init(id: UUID = UUID(), title: String, color: Color) {
//        self.id = id
//        self.title = title
//        self.color = color
//    }
//    
//    // Transferable conformance для современного Drag & Drop
//    static var transferRepresentation: some TransferRepresentation {
//        CodableRepresentation(contentType: .draggableItem)
//    }
//    
//    // Codable conformance для Color
//    enum CodingKeys: String, CodingKey {
//        case id, title, colorName
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(UUID.self, forKey: .id)
//        title = try container.decode(String.self, forKey: .title)
//        let colorName = try container.decode(String.self, forKey: .colorName)
//        color = Self.colorFromString(colorName)
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(title, forKey: .title)
//        try container.encode(Self.stringFromColor(color), forKey: .colorName)
//    }
//    
//    static func colorFromString(_ name: String) -> Color {
//        switch name {
//        case "blue": return .blue
//        case "green": return .green
//        case "red": return .red
//        case "orange": return .orange
//        case "purple": return .purple
//        default: return .gray
//        }
//    }
//    
//    static func stringFromColor(_ color: Color) -> String {
//        switch color {
//        case .blue: return "blue"
//        case .green: return "green"
//        case .red: return "red"
//        case .orange: return "orange"
//        case .purple: return "purple"
//        default: return "gray"
//        }
//    }
//}
//
//// MARK: - UTType Extension
//extension UTType {
//    static let draggableItem = UTType(exportedAs: "com.myapp.draggableitem")
//}
//
//// MARK: - ViewModel
//@MainActor
//class DragDropViewModel: ObservableObject {
//    @Published var sourceItems: [DraggableItem]
//    @Published var targetItems: [DraggableItem]
//    @Published var draggedItem: DraggableItem?
//    
//    init() {
//        self.sourceItems = [
//            DraggableItem(title: "Task 1", color: .blue),
//            DraggableItem(title: "Task 2", color: .green),
//            DraggableItem(title: "Task 3", color: .red),
//            DraggableItem(title: "Task 4", color: .orange),
//            DraggableItem(title: "Task 5", color: .purple)
//        ]
//        self.targetItems = []
//    }
//    
//    // MARK: - Business Logic
//    
//    func startDragging(_ item: DraggableItem) {
//        draggedItem = item
//    }
//    
//    func moveItem(from source: ItemSource, to destination: ItemSource, at index: Int?) {
//        guard let item = draggedItem else { return }
//        
//        // Определяем текущее местоположение элемента
//        let currentSource: ItemSource = sourceItems.contains(where: { $0.id == item.id }) ? .source : .target
//        
//        // Удаляем из текущего источника
//        removeItem(item, from: currentSource)
//        
//        // Добавляем в назначение
//        addItem(item, to: destination, at: index)
//        
//        draggedItem = nil
//    }
//    
//    func reorderItems(in source: ItemSource, from: IndexSet, to: Int) {
//        switch source {
//        case .source:
//            sourceItems.move(fromOffsets: from, toOffset: to)
//        case .target:
//            targetItems.move(fromOffsets: from, toOffset: to)
//        }
//    }
//    
//    private func removeItem(_ item: DraggableItem, from source: ItemSource) {
//        switch source {
//        case .source:
//            sourceItems.removeAll { $0.id == item.id }
//        case .target:
//            targetItems.removeAll { $0.id == item.id }
//        }
//    }
//    
//    private func addItem(_ item: DraggableItem, to destination: ItemSource, at index: Int?) {
//        switch destination {
//        case .source:
//            if let index = index, index < sourceItems.count {
//                sourceItems.insert(item, at: index)
//            } else {
//                sourceItems.append(item)
//            }
//        case .target:
//            if let index = index, index < targetItems.count {
//                targetItems.insert(item, at: index)
//            } else {
//                targetItems.append(item)
//            }
//        }
//    }
//    
//    func resetItems() {
//        sourceItems = [
//            DraggableItem(title: "Task 1", color: .blue),
//            DraggableItem(title: "Task 2", color: .green),
//            DraggableItem(title: "Task 3", color: .red),
//            DraggableItem(title: "Task 4", color: .orange),
//            DraggableItem(title: "Task 5", color: .purple)
//        ]
//        targetItems = []
//        draggedItem = nil
//    }
//}
//
//// MARK: - Supporting Types
//enum ItemSource {
//    case source
//    case target
//}
//
//// MARK: - Views
//struct DragDropView: View {
//    @StateObject private var viewModel = DragDropViewModel()
//    
//    var body: some View {
//        NavigationView {
//            HStack(spacing: 20) {
//                // Source list
//                ItemListView(
//                    title: "Available",
//                    items: viewModel.sourceItems,
//                    source: .source,
//                    viewModel: viewModel
//                )
//                
//                Divider()
//                
//                // Target list
//                ItemListView(
//                    title: "Selected",
//                    items: viewModel.targetItems,
//                    source: .target,
//                    viewModel: viewModel
//                )
//            }
//            .padding()
//            .navigationTitle("Drag & Drop Demo")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Reset") {
//                        viewModel.resetItems()
//                    }
//                }
//            }
//        }
//    }
//}
//
//struct ItemListView: View {
//    let title: String
//    let items: [DraggableItem]
//    let source: ItemSource
//    @ObservedObject var viewModel: DragDropViewModel
//    @State private var isTargeted = false
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text(title)
//                .font(.headline)
//                .foregroundColor(.secondary)
//            
//            ScrollView {
//                LazyVStack(spacing: 8) {
//                    ForEach(items) { item in
//                        DraggableItemView(item: item)
//                            .draggable(item) {
//                                DraggableItemView(item: item)
//                                    .opacity(0.8)
//                                    .onAppear {
//                                        viewModel.startDragging(item)
//                                    }
//                            }
//                            .dropDestination(for: DraggableItem.self) { droppedItems, location in
//                                guard let draggedItem = viewModel.draggedItem,
//                                      let toIndex = items.firstIndex(where: { $0.id == item.id }) else {
//                                    return false
//                                }
//                                
//                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
//                                    let currentSource: ItemSource = viewModel.sourceItems.contains(where: { $0.id == draggedItem.id }) ? .source : .target
//                                    
//                                    if currentSource == source {
//                                        // Переупорядочивание в том же списке
//                                        if let fromIndex = items.firstIndex(where: { $0.id == draggedItem.id }),
//                                           fromIndex != toIndex {
//                                            viewModel.reorderItems(in: source, from: IndexSet(integer: fromIndex), to: toIndex > fromIndex ? toIndex + 1 : toIndex)
//                                        }
//                                    } else {
//                                        // Перемещение между списками
//                                        viewModel.moveItem(from: currentSource, to: source, at: toIndex)
//                                    }
//                                }
//                                return true
//                            }
//                    }
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.vertical, items.isEmpty ? 20 : 0)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(isTargeted ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .strokeBorder(isTargeted ? Color.blue : Color.clear, lineWidth: 2)
//                    )
//            )
//            .dropDestination(for: DraggableItem.self) { droppedItems, location in
//                guard let draggedItem = viewModel.draggedItem else { return false }
//                
//                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
//                    let currentSource: ItemSource = viewModel.sourceItems.contains(where: { $0.id == draggedItem.id }) ? .source : .target
//                    viewModel.moveItem(from: currentSource, to: source, at: nil)
//                }
//                return true
//            } isTargeted: { targeted in
//                isTargeted = targeted
//            }
//            
//            Text("\(items.count) items")
//                .font(.caption)
//                .foregroundColor(.secondary)
//        }
//        .frame(maxWidth: .infinity)
//    }
//}
//
//struct DraggableItemView: View {
//    let item: DraggableItem
//    
//    var body: some View {
//        HStack {
//            RoundedRectangle(cornerRadius: 4)
//                .fill(item.color)
//                .frame(width: 4)
//            
//            Text(item.title)
//                .font(.body)
//                .foregroundColor(.primary)
//            
//            Spacer()
//            
//            Image(systemName: "line.3.horizontal")
//                .foregroundColor(.secondary)
//                .font(.caption)
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 8)
//                .fill(Color(uiColor: .systemBackground))
//                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
//        )
//        .contentShape(Rectangle())
//    }
//}
//
//// MARK: - Preview
//struct DragDropView_Previews: PreviewProvider {
//    static var previews: some View {
//        DragDropView()
//    }
//}
