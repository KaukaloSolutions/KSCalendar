//
//  ContentView.swift
//  Calendar
//
//  Created by Janne Jussila on 26.1.2022.
//

import SwiftUI



/// A calendar having similar look as DatePicker. Calendar is capable to show
/// two individual events for each date i.e. primary and secondary.  CalendarView requires
/// to have an object inheriting from CalendarData that is responsible for individual daily items.
///
/// Basic initialization:
///     CalendarView(:CalendarData)
public struct CalendarView: View {
    
    @StateObject private var calendar: CalendarViewModel
    
    /// CalendarView init
    /// - Parameter calendar: an object inferitng from CalendarData
    /// - Parameter hideMonthView: in case monthView is not needed, set true, default = false
    public init(calendar: CalendarData, hideMonthView: Bool = false) {
        self._calendar = StateObject(wrappedValue: CalendarViewModel(calendarData: calendar, hideMonthView: hideMonthView))
    }
    
    public var body: some View {
        VStack {
            calendarSelection
                .padding([.horizontal, .bottom])
            calendar(mode: calendar.isDetail)
                .padding(.horizontal)
            Spacer()
        }
        .environmentObject(calendar)
    }
    
    private var calendarSelection: some View {
        HStack(spacing: 30) {
            HStack(spacing: 5) {
                Text(calendar.title)
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(calendar.isDetail ? 0 : 90))
            }
            .foregroundColor(Color.blue)
            .onTapGesture {
                withAnimation {
                    calendar.monthYearToggle()
                }
            }
            Spacer()
            Button {
                    calendar.isDetail ?
                    calendar.previousMonth() :
                    calendar.previousYear()
            } label: {
                Image(systemName: "chevron.left")
            }
            Button {
                    calendar.isDetail ?
                    calendar.nextMonth() :
                    calendar.nextYear()
            } label: {
                Image(systemName: "chevron.right")
            }
        }
    }
    
    @ViewBuilder func calendar(mode month: Bool) -> some View {
        if month {
            if calendar.monthViewIsHidded {
                EmptyView()
            } else {
                CalendarMonthGrid(month: calendar.selectedMonth,
                                  year: calendar.selectedYear)
                    .gesture(swipeGesture(left: calendar.nextMonth,
                                          right: calendar.previousMonth))
            }
        } else {
            CalendarYearGrid()
                .gesture(swipeGesture(left: calendar.nextYear,
                                      right: calendar.previousYear))
        }
    }
    
    
    private func swipeGesture(left: @escaping () -> Void, right: @escaping () -> Void) -> _EndedGesture<DragGesture> {
       DragGesture(minimumDistance: 100)
            .onEnded { value in
                guard abs(value.translation.width) > 100 else { return }
                if value.translation.width < 0 {
                    left()
                } else {
                    right()
                }
            }
    }
}


private struct CalendarItem: Identifiable {
    let value: Int
    var id: Int { value }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView(calendar: CalendarData())
    }
}
