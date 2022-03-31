//
//  CalendarYearGrid.swift
//  Calendar
//
//  Created by Janne Jussila on 27.1.2022.
//

import SwiftUI

struct CalendarYearGrid: View {
    
    @EnvironmentObject var calendar: CalendarViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ForEach(Quarters.allCases) { quarter in
                quarterView(for: quarter)
            }
            .padding(.bottom)
            Spacer()
        }
    }
    
    @ViewBuilder private func quarterView(for quarter: Quarters) -> some View {
        let months = calendar.months
        HStack {
            ForEach(0..<3) { index in
                VStack(alignment: .center, spacing: 0) {
                    HStack {
                        Text(months[quarter.rawValue * 3 + index])
                            .font(.callout)
                        Spacer()
                    }
                    CalendarMonthGrid(month: quarter.rawValue * 3 + index + 1,
                                      year: calendar.selectedYear)
                        .disabled(true)
                        .onTapGesture {
                            withAnimation {
                                calendar.didSelect(month: quarter.rawValue * 3 + index + 1,
                                                   on: calendar.selectedYear)
                            }
                        }
                    Spacer()
                }
            }
        }
    }
    
    private enum Quarters: Int, CaseIterable, Identifiable {
        case first = 0, second, third, fourth
        var id: Int { rawValue }
    }
    
}

struct CalendarYearGrid_Previews: PreviewProvider {
    
    struct CalendarYearGridWrapper: View {
        
        @StateObject var calendar = CalendarViewModel(calendarData: CalendarData())
        var body: some View {
            CalendarYearGrid()
                .environmentObject(calendar)
        }
    }
    
    static var previews: some View {
        CalendarYearGridWrapper()
    }
}
