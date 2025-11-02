//
//  EventListView.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 11/1/25.
//

import SwiftUI

// MARK: - Event List View
struct EventListView: View {
    let date: Date
    let events: [CalendarEvent]
    let onDelete: (CalendarEvent) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(date.formatted(date: .complete, time: .omitted))
                .font(.headline)
                .foregroundStyle(.secondary)
            
            if events.isEmpty {
                emptyStateView
            } else {
                eventsList
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            
            Text("No events for this day")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
    
    private var eventsList: some View {
        VStack(spacing: 8) {
            ForEach(events) { event in
                EventRow(event: event, onDelete: {
                    onDelete(event)
                })
            }
        }
    }
}

// MARK: - Event Row Component
struct EventRow: View {
    let event: CalendarEvent
    let onDelete: () -> Void
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(event.color)
                .frame(width: 12, height: 12)
            
            Text(event.title)
                .font(.body)
            
            Spacer()
            
            Button(action: { showDeleteConfirmation = true }) {
                Image(systemName: "trash")
                    .font(.body)
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .confirmationDialog(
            "Delete Event",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete '\(event.title)'?")
        }
    }
}
