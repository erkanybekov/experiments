//
//  CalendarView.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 11/1/25.
//

import SwiftUI

// MARK: - Models
struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let events: [CalendarEvent]
    
    var hasEvents: Bool { !events.isEmpty }
}

// MARK: - Event Model
struct CalendarEvent: Identifiable, Equatable {
    let id: UUID
    let title: String
    let date: Date
    let color: Color
    
    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        color: Color = .blue
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.color = color
    }
}

// MARK: - ViewModel
@Observable
final class CalendarViewModel {
    
    // MARK: - Published State
    private(set) var days: [CalendarDay] = []
    private(set) var currentMonth: Date
    private(set) var events: [CalendarEvent] = []
    
    var selectedDate: Date? {
        didSet {
            updateDays()
        }
    }
    
    // MARK: - Dependencies
    private let calendar: Calendar
    private let today: Date
    
    // MARK: - Computed Properties
    var monthYearString: String {
        currentMonth.formatted(.dateTime.month(.wide).year())
    }
    
    // ← NEW: Get events for selected date
    var selectedDateEvents: [CalendarEvent] {
        guard let selectedDate else { return [] }
        return eventsForDate(selectedDate)
    }
    
    // MARK: - Initialization
    init(
        calendar: Calendar = .current,
        initialDate: Date = Date()
    ) {
        self.calendar = calendar
        self.today = calendar.startOfDay(for: initialDate)
        self.currentMonth = calendar.startOfDay(for: initialDate)
        updateDays()
    }
    
    // MARK: - Public Methods
    func moveToNextMonth() {
        guard let nextMonth = calendar.date(
            byAdding: .month,
            value: 1,
            to: currentMonth
        ) else { return }
        currentMonth = nextMonth
        updateDays()
    }
    
    func moveToPreviousMonth() {
        guard let previousMonth = calendar.date(
            byAdding: .month,
            value: -1,
            to: currentMonth
        ) else { return }
        currentMonth = previousMonth
        updateDays()
    }
    
    func selectDate(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
    }
    
    // ← NEW: Add event method
    func addEvent(title: String, date: Date, color: Color = .blue) {
        let event = CalendarEvent(
            title: title,
            date: calendar.startOfDay(for: date),
            color: color
        )
        events.append(event)
        updateDays()  // Refresh to show event indicator
    }
    
    // ← NEW: Delete event method
    func deleteEvent(_ event: CalendarEvent) {
        events.removeAll { $0.id == event.id }
        updateDays()
    }
    
    // ← NEW: Get events for a specific date
    func eventsForDate(_ date: Date) -> [CalendarEvent] {
        let targetDate = calendar.startOfDay(for: date)
        return events.filter { calendar.isDate($0.date, inSameDayAs: targetDate) }
    }
    
    // MARK: - Private Methods
    private func updateDays() {
        days = generateDaysForMonth(currentMonth)
    }
    
    private func generateDaysForMonth(_ month: Date) -> [CalendarDay] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else { return [] }
        
        var days: [CalendarDay] = []
        var currentDate = monthFirstWeek.start
        
        // Generate 6 weeks (42 days) to ensure consistent grid
        for _ in 0..<42 {
            let isInCurrentMonth = calendar.isDate(currentDate, equalTo: month, toGranularity: .month)
            let isToday = calendar.isDate(currentDate, inSameDayAs: today)
            let isSelected = selectedDate.map { calendar.isDate(currentDate, inSameDayAs: $0) } ?? false
            let dayEvents = eventsForDate(currentDate)
            
            days.append(CalendarDay(
                date: currentDate,
                isCurrentMonth: isInCurrentMonth,
                isToday: isToday,
                isSelected: isSelected,
                events: dayEvents
            ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
}

// MARK: - View
// MARK: - Updated Calendar View
struct CalendarView: View {
    @State private var viewModel = CalendarViewModel()
    @State private var showAddEventSheet = false
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calendar Section
                calendarSection
                
                Divider()
                    .padding(.vertical, 8)
                
                // Events Section
                eventsSection
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if viewModel.selectedDate != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: { showAddEventSheet = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddEventSheet) {
                if let selectedDate = viewModel.selectedDate {
                    AddEventSheet(selectedDate: selectedDate) { title, color in
                        viewModel.addEvent(title: title, date: selectedDate, color: color)
                    }
                }
            }
        }
    }
    
    private var calendarSection: some View {
        VStack(spacing: 16) {
            headerView
            weekdayLabelsView
            daysGridView
        }
        .padding()
    }
    
    private var eventsSection: some View {
        ScrollView {
            if let selectedDate = viewModel.selectedDate {
                EventListView(
                    date: selectedDate,
                    events: viewModel.selectedDateEvents,
                    onDelete: { event in
                        viewModel.deleteEvent(event)
                    }
                )
            } else {
                selectDatePrompt
            }
        }
    }
    
    private var selectDatePrompt: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.tap")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("Select a date to view or add events")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
    
    private var headerView: some View {
        HStack {
            Button(action: viewModel.moveToPreviousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
            }
            
            Spacer()
            
            Text(viewModel.monthYearString)
                .font(.title2.bold())
            
            Spacer()
            
            Button(action: viewModel.moveToNextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
            }
        }
        .buttonStyle(.plain)
    }
    
    private var weekdayLabelsView: some View {
        HStack(spacing: 8) {
            ForEach(weekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var daysGridView: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.days) { day in
                Text(day.date.formatted(.dateTime.day()))
//                DayCell(day: day) {
//                    viewModel.selectDate(day.date)
//                }
            }
        }
    }
}

// MARK: - Day Cell Component
struct DayCell: View {
    let day: CalendarDay
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(day.date.formatted(.dateTime.day()))
                    .font(.body)
                    .foregroundStyle(foregroundColor)
                
                // ← NEW: Event indicator dots
                if day.hasEvents {
                    HStack(spacing: 2) {
                        ForEach(day.events.prefix(3)) { event in  // Show max 3 dots
                            Circle()
                                .fill(event.color)
                                .frame(width: 4, height: 4)
                        }
                    }
                } else {
                    Spacer()
                        .frame(height: 4)  // Maintain consistent height
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)  // ← Increased height for indicator
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))  // ← Changed to rounded rectangle
        }
        .buttonStyle(.plain)
        .opacity(day.isCurrentMonth ? 1 : 0.3)
    }
    
    private var foregroundColor: Color {
        if day.isSelected {
            return .white
        } else if day.isToday {
            return .accentColor
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if day.isSelected {
            return .accentColor
        } else if day.isToday {
            return .accentColor.opacity(0.2)
        } else {
            return .clear
        }
    }
}

// MARK: - Preview
#Preview {
    CalendarView()
}
