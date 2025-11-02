//
//  CalendarVM.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 11/2/25.
//
import SwiftUI

// ❌ Smelly ViewModel -> Clear ✅
@Observable
final class CalendarVM {
    // state
    private(set) var days: [Day] = []
    private(set) var events: [Event] = []
    private(set) var currentMonth: Date
    
    var selectedDate: Date? {
        didSet {
            updateDays()
        }
    }
    
    //Deps
    private let calendar: Calendar
    private let todayDate: Date
    
    init(calendar: Calendar = .current, initialDate: Date = Date()) {
        self.calendar = calendar
        self.todayDate = calendar.startOfDay(for: initialDate)
        self.currentMonth = calendar.startOfDay(for: initialDate)
        updateDays()
    }
    
    func eventForDate(date: Date) -> [Event] {
        //target
        let targetDate = calendar.startOfDay(for: date)
        //return with events filter
        return events.filter { calendar.isDate($0.date, inSameDayAs: targetDate)}
    }
    
    func generateSixWeek(_ month: Date) -> [Day] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else { return []}
        
        var days: [Day] = []
        var currentDate = monthFirstWeek.start
        
        // generate six weeks (42 days)
        for _ in 0..<42 {
            let isCurrentMonth = calendar.isDate(currentDate, equalTo: month, toGranularity: .month)
            let isToday = calendar.isDate(currentDate, inSameDayAs: todayDate)
            let isSelected  = selectedDate.map { calendar.isDate(currentDate, inSameDayAs: $0 )} ?? false
            let dayEvents = eventForDate(date: currentDate)
            
            // Append to days
            days.append(Day(
                    date: currentDate,
                    isToday: isToday,
                    isSelected: isSelected,
                    events: dayEvents
                ))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        
        }
        return days
    }
    
    func addEvent(title: String, date: Date, color: Color = .blue) {
        let event = Event(title: title, date: calendar.startOfDay(for: date), color: color)
        events.append(event)
    }
    
    private func updateDays() {
        days = generateSixWeek(currentMonth)
    }
}
