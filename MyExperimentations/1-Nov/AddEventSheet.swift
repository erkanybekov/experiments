//
//  AddEventSheet.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 11/1/25.
//

import SwiftUI

// MARK: - Add Event Sheet
struct AddEventSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let selectedDate: Date
    let onSave: (String, Color) -> Void
    
    @State private var eventTitle: String = ""
    @State private var selectedColor: Color = .blue
    
    private let availableColors: [Color] = [
        .blue, .red, .green, .orange, .purple, .pink, .yellow, .cyan
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Event title", text: $eventTitle)
                    
                    DatePicker(
                        "Date",
                        selection: .constant(selectedDate),
                        displayedComponents: .date
                    )
                    .disabled(true)  // Show but don't allow editing
                }
                
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                        ForEach(availableColors, id: \.self) { color in
                            ColorButton(
                                color: color,
                                isSelected: selectedColor == color
                            ) {
                                selectedColor = color
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Add Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(eventTitle, selectedColor)
                        dismiss()
                    }
                    .disabled(eventTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

// MARK: - Color Selection Button
struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 44, height: 44)
                
                if isSelected {
                    Circle()
                        .stroke(Color.primary, lineWidth: 3)
                        .frame(width: 50, height: 50)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
