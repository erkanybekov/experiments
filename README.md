# SwiftUI Calendar App with Events

A production-ready calendar application built with SwiftUI following MVVM architecture and iOS best practices.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Implementation Steps](#implementation-steps)
- [Key Components](#key-components)
- [Testing](#testing)
- [Best Practices](#best-practices)

## ✨ Features

- 📅 Monthly calendar view with navigation
- 🎯 Date selection with visual feedback
- ➕ Add events to specific dates
- 🎨 Color-coded events (8 colors)
- 📝 Event list view for selected date
- 🗑️ Delete events with confirmation
- 📊 Event indicators on calendar days
- 🎭 Empty states and user feedback
- ♿ Accessibility ready

## 🏗️ Architecture

This app follows **MVVM (Model-View-ViewModel)** pattern:

```
┌─────────────┐
│    View     │ ← Pure UI, no business logic
└──────┬──────┘
       │ Observes
┌──────▼──────┐
│  ViewModel  │ ← Business logic, state management
└──────┬──────┘
       │ Uses
┌──────▼──────┐
│    Model    │ ← Data structures
└─────────────┘
```

### Core Principles

- **Separation of Concerns**: Each layer has a single responsibility
- **Observable State**: Reactive UI updates with `@Observable`
- **Dependency Injection**: Testable and flexible
- **Immutable Models**: Thread-safe data structures
- **Component Composition**: Reusable UI components

## 🚀 Getting Started

### Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Quick Start

1. Create a new SwiftUI project in Xcode
2. Follow the implementation steps below
3. Run and test!

## 📝 Implementation Steps

### Step 1: Create Data Models

Create the foundational data structures:

**CalendarEvent** - Represents a single event
```swift
struct CalendarEvent: Identifiable, Equatable {
    let id: UUID
    let title: String
    let date: Date
    let color: Color
}
```

**CalendarDay** - Represents a day in the calendar
```swift
struct CalendarDay: Identifiable {
    let id: UUID
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let isSelected: Bool
    let events: [CalendarEvent]
    
    var hasEvents: Bool {
        !events.isEmpty
    }
}
```

**Key Points:**
- `Identifiable` for SwiftUI list iteration
- `Equatable` for comparison operations
- Computed properties for convenience

---

### Step 2: Build the ViewModel

Create `CalendarViewModel` to manage state and business logic:

```swift
@Observable
final class CalendarViewModel {
    // State
    private(set) var days: [CalendarDay] = []
    private(set) var currentMonth: Date
    private(set) var events: [CalendarEvent] = []
    var selectedDate: Date?
    
    // Dependencies
    private let calendar: Calendar
    private let today: Date
    
    // Public Methods
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
```

**Key Responsibilities:**
- Month navigation logic
- Date selection management
- Event CRUD operations
- Generate calendar days (42-day grid)
- Filter events by date

**Important Patterns:**
- Use `private(set)` for read-only external access
- Inject dependencies (Calendar) for testability
- Keep methods focused and single-purpose
- Use `calendar.startOfDay()` for date comparison

---

### Step 3: Create UI Components

Build reusable view components:

#### DayCell Component
```swift
struct DayCell: View {
    let day: CalendarDay
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(day.date.formatted(.dateTime.day()))
                
                // Event indicators (max 3 dots)
                if day.hasEvents {
                    HStack(spacing: 2) {
                        ForEach(day.events.prefix(3)) { event in
                            Circle()
                                .fill(event.color)
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
        }
    }
}
```

**Design Decisions:**
- Show max 3 event dots to avoid overcrowding
- Maintain consistent height with/without events
- Visual states: selected, today, current month
- Button style with proper tap target

#### EventRow Component
```swift
struct EventRow: View {
    let event: CalendarEvent
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Circle().fill(event.color).frame(width: 12, height: 12)
            Text(event.title)
            Spacer()
            Button("Delete") { onDelete() }
        }
        .confirmationDialog(...)  // Delete confirmation
    }
}
```

**Best Practices:**
- Always confirm destructive actions
- Show event color for quick recognition
- Keep actions accessible

---

### Step 4: Build Event Management UI

#### Add Event Sheet
```swift
struct AddEventSheet: View {
    let selectedDate: Date
    let onSave: (String, Color) -> Void
    
    @State private var eventTitle: String = ""
    @State private var selectedColor: Color = .blue
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Event title", text: $eventTitle)
                    DatePicker("Date", selection: .constant(selectedDate))
                        .disabled(true)
                }
                
                Section("Color") {
                    // Color picker grid
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { 
                        onSave(eventTitle, selectedColor)
                    }
                    .disabled(eventTitle.isEmpty)
                }
            }
        }
    }
}
```

**UX Considerations:**
- Disable save button until title entered
- Show but disable date picker (for context)
- Standard sheet presentation pattern
- Clear cancel/save actions

#### Event List View
```swift
struct EventListView: View {
    let date: Date
    let events: [CalendarEvent]
    let onDelete: (CalendarEvent) -> Void
    
    var body: some View {
        VStack {
            Text(date.formatted(date: .complete, time: .omitted))
            
            if events.isEmpty {
                // Empty state
                Image(systemName: "calendar.badge.plus")
                Text("No events for this day")
            } else {
                ForEach(events) { event in
                    EventRow(event: event, onDelete: { onDelete(event) })
                }
            }
        }
    }
}
```

**Empty State Design:**
- Clear visual indicator (icon + text)
- Helpful messaging
- Maintains consistent spacing

---

### Step 5: Assemble Main CalendarView

```swift
struct CalendarView: View {
    @State private var viewModel = CalendarViewModel()
    @State private var showAddEventSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calendar grid section
                calendarSection
                
                Divider()
                
                // Events list section
                ScrollView {
                    if let selectedDate = viewModel.selectedDate {
                        EventListView(
                            date: selectedDate,
                            events: viewModel.selectedDateEvents,
                            onDelete: viewModel.deleteEvent
                        )
                    } else {
                        // Selection prompt
                    }
                }
            }
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
                AddEventSheet(...)
            }
        }
    }
}
```

**Layout Strategy:**
- Split view: Calendar top, Events bottom
- Scrollable events section
- Context-aware toolbar (only shows add button when date selected)
- Sheet presentation for adding events

---

## 🔑 Key Components

### Models
| Component | Purpose | Key Properties |
|-----------|---------|----------------|
| `CalendarEvent` | Event data | id, title, date, color |
| `CalendarDay` | Day state | date, events, selection state |

### ViewModel
| Method | Purpose |
|--------|---------|
| `addEvent()` | Create new event |
| `deleteEvent()` | Remove event |
| `eventsForDate()` | Filter events by date |
| `selectDate()` | Handle date selection |
| `moveToNextMonth()` | Navigate months |
| `generateDaysForMonth()` | Build calendar grid |

### Views
| Component | Purpose |
|-----------|---------|
| `CalendarView` | Main container |
| `DayCell` | Individual day display |
| `EventRow` | Event list item |
| `AddEventSheet` | Event creation form |
| `EventListView` | Events for selected date |
| `ColorButton` | Color picker option |

---

## 🧪 Testing

### Unit Tests for ViewModel

```swift
final class CalendarViewModelTests: XCTestCase {
    func testAddEvent() {
        let viewModel = CalendarViewModel()
        let date = Date()
        
        viewModel.addEvent(title: "Test", date: date, color: .blue)
        
        XCTAssertEqual(viewModel.events.count, 1)
        XCTAssertEqual(viewModel.events.first?.title, "Test")
    }
    
    func testDeleteEvent() {
        let viewModel = CalendarViewModel()
        viewModel.addEvent(title: "Test", date: Date(), color: .blue)
        let event = viewModel.events.first!
        
        viewModel.deleteEvent(event)
        
        XCTAssertEqual(viewModel.events.count, 0)
    }
    
    func testEventsForDate() {
        let viewModel = CalendarViewModel()
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        viewModel.addEvent(title: "Today", date: today, color: .blue)
        viewModel.addEvent(title: "Tomorrow", date: tomorrow, color: .red)
        
        XCTAssertEqual(viewModel.eventsForDate(today).count, 1)
        XCTAssertEqual(viewModel.eventsForDate(tomorrow).count, 1)
    }
    
    func testMonthNavigation() {
        let viewModel = CalendarViewModel()
        let initialMonth = viewModel.currentMonth
        
        viewModel.moveToNextMonth()
        
        XCTAssertNotEqual(initialMonth, viewModel.currentMonth)
    }
}
```

### Testing Strategy
- ✅ Test ViewModel logic without UI
- ✅ Mock dependencies for isolation
- ✅ Test edge cases (empty states, date boundaries)
- ✅ Verify state changes trigger UI updates

---

## 🎯 Best Practices Applied

### 1. **MVVM Architecture**
```swift
// ❌ Bad: Logic in View
struct CalendarView: View {
    @State private var events: [Event] = []
    
    func addEvent() {
        // Complex logic here
    }
}

// ✅ Good: Logic in ViewModel
struct CalendarView: View {
    @State private var viewModel = CalendarViewModel()
}
```

### 2. **Immutable Models**
```swift
// ✅ All properties are let (immutable)
struct CalendarEvent: Identifiable {
    let id: UUID
    let title: String
    let date: Date
    let color: Color
}
```

### 3. **Dependency Injection**
```swift
// ✅ Inject Calendar for testability
init(calendar: Calendar = .current, initialDate: Date = Date()) {
    self.calendar = calendar
    self.today = calendar.startOfDay(for: initialDate)
}
```

### 4. **Component Composition**
```swift
// ✅ Small, reusable components
struct DayCell: View { ... }
struct EventRow: View { ... }
struct ColorButton: View { ... }
```

### 5. **State Management**
```swift
// ✅ Single source of truth
@Observable final class CalendarViewModel {
    private(set) var events: [CalendarEvent] = []  // Read-only externally
    
    func addEvent(...) {  // Controlled mutation
        events.append(...)
    }
}
```

### 6. **Safe Date Handling**
```swift
// ✅ Always use Calendar for date operations
let targetDate = calendar.startOfDay(for: date)
events.filter { calendar.isDate($0.date, inSameDayAs: targetDate) }

// ❌ Avoid: Direct date comparison (timezone issues)
events.filter { $0.date == date }
```

### 7. **User Feedback**
```swift
// ✅ Empty states
if events.isEmpty {
    EmptyStateView()
}

// ✅ Confirmation dialogs
.confirmationDialog("Delete Event", ...) {
    Button("Delete", role: .destructive) { ... }
}

// ✅ Disabled states
.disabled(eventTitle.isEmpty)
```

### 8. **Performance**
```swift
// ✅ LazyVGrid for efficient rendering
LazyVGrid(columns: columns) {
    ForEach(viewModel.days) { day in
        DayCell(day: day)
    }
}

// ✅ Fixed 42-day grid (prevents layout shifts)
for _ in 0..<42 { ... }
```

---

## 📚 Code Organization

```
CalendarApp/
├── Models/
│   ├── CalendarEvent.swift
│   └── CalendarDay.swift
├── ViewModels/
│   └── CalendarViewModel.swift
├── Views/
│   ├── CalendarView.swift
│   ├── DayCell.swift
│   ├── EventRow.swift
│   ├── AddEventSheet.swift
│   ├── EventListView.swift
│   └── ColorButton.swift
└── Tests/
    └── CalendarViewModelTests.swift
```

---

## 🚀 Future Enhancements

Potential features to add:

- [ ] **Event Editing** - Modify existing events
- [ ] **Time Support** - Add specific times (not just all-day)
- [ ] **Persistence** - Save events (UserDefaults/CoreData/SwiftData)
- [ ] **Recurring Events** - Daily, weekly, monthly patterns
- [ ] **Search & Filter** - Find events by title or color
- [ ] **Event Details** - Add descriptions, locations, reminders
- [ ] **Multiple Calendars** - Separate work/personal categories
- [ ] **Export/Import** - iCal format support
- [ ] **Widgets** - Home screen calendar widget
- [ ] **Dark Mode** - Enhanced dark mode support

---

## 📖 Key Takeaways

1. **MVVM keeps code organized** - Views handle UI, ViewModels handle logic
2. **Dependency injection enables testing** - Mock dependencies easily
3. **Observable pattern simplifies state** - Automatic UI updates
4. **Component composition improves reusability** - Build once, use everywhere
5. **User feedback matters** - Empty states, confirmations, disabled states
6. **Date handling needs care** - Always use Calendar for comparisons
7. **Performance through lazy loading** - LazyVGrid for large datasets
8. **Type safety prevents bugs** - Strong typing throughout

---

## 📄 License

MIT License - Feel free to use in your projects!

---

## 🤝 Contributing

Built following Apple's SwiftUI best practices and Human Interface Guidelines.

For questions or improvements, feel free to open an issue or submit a PR!

---

**Happy Coding! 🎉**
