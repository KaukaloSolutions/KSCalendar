//
//  CalendarYearGrid.swift
//  Calendar
//
//  Created by Janne Jussila on 27.1.2022.
//

import SwiftUI

struct KSCalendarYearGrid: View {
    
    @EnvironmentObject var calendar: KSCalendarViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            ForEach(Quarters.allCases) { quarter in
                quarterView(for: quarter)
            }
        }
    }
    
    @ViewBuilder private func quarterView(for quarter: Quarters) -> some View {
        let months = calendar.months
        HStack(alignment: .top, spacing: 5) {
            ForEach(0..<3) { index in
                VStack(alignment: .center, spacing: 5) {
                    HStack {
                        Text(months[quarter.rawValue * 3 + index])
                            .font(.callout)
                        Spacer()
                    }
                    KSCalendarMonthGrid(month: quarter.rawValue * 3 + index + 1,
                                        year: calendar.selectedYear)
                    .disabled(true)
                    .onTapGesture {
                        calendar.didSelect(month: quarter.rawValue * 3 + index + 1,
                                           on: calendar.selectedYear)
                    }
                }
            }
            .padding([.leading, .trailing], 2)
        }
    }
    
    private enum Quarters: Int, CaseIterable, Identifiable {
        case first = 0, second, third, fourth
        var id: Int { rawValue }
    }
    
}

struct CalendarYearGrid_Previews: PreviewProvider {
    
    class PreviewData: KSCalendarData {
        struct Item: KSCalendarDayItem {
            let day: Int
            var hasPrimaryEvent: Bool
            var hasSecondaryEvent: Bool

        }
        
        override func calendarDayItems(for month: Int, and year: Int) -> [KSCalendarDayItem] {
            return [Item(day: 1,
                            hasPrimaryEvent: true,
                            hasSecondaryEvent: true)]
        }
    }
    
    struct CalendarYearGridWrapper: View {
        
        @StateObject var calendar = KSCalendarViewModel(calendarData: PreviewData(), selectedDate: Date())
        var body: some View {
            KSCalendarYearGrid()
                .environmentObject(calendar)
        }
    }
    
    static var previews: some View {
        CalendarYearGridWrapper()
    }
}


