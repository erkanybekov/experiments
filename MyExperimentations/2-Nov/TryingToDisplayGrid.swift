//
//  TryingToDisplayGrid.swift
//  MyExperimentations
//
//  Created by Erlan Kanybekov on 11/2/25.
//
import SwiftUI

struct TryingToDisplayGrid: View {
    @State var vm = CalendarVM()
    
    private var column = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private var weekDaySymbols = Calendar.current.shortWeekdaySymbols
    
    var body: some View {
        VStack {
            HStack(spacing: 8) {
                ForEach(weekDaySymbols, id: \.self) { WeekName in
                    Text(WeekName)
                        .frame(maxWidth: .infinity)
                        .bold()
                }
            }
            LazyVGrid(columns: column) {
                ForEach(vm.days) { day in
                    Text(day.date.formatted(.dateTime.day()))
                }
            }
        }
    }
}

#Preview {
    TryingToDisplayGrid()
}
