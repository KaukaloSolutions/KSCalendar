//
//  ContentView.swift
//  Calendar
//
//  Created by Janne Jussila /Users/jannejussila/Desktop/Developer/Kaukalo/KaukaloApps/Calendar/KSCalendar/Sources/KSCalendaron 26.1.2022.
//

import SwiftUI

/// A calendar having similar look as DatePicker. Calendar is capable to show
/// two individual events for each date i.e. primary and secondary.  KSCalendarView requires
/// to have an object inheriting from CalendarData that is responsible for individual daily items.
///
/// Basic initialization:
///     CalendarView(:CalendarData)
public struct KSCalendarView: View {
    
   
    
    @StateObject private var calendar: KSCalendarViewModel
    
    /// CalendarView init
    /// - Parameter calendar: an object inferitng from CalendarData
    /// - Parameter hideMonthView: in case monthView is not needed, set true, default = false
    public init(calendar: KSCalendarDataSource, selectedDate: Date, hideMonthView: Bool = false, hideSecondaryEvent: Bool = false, delegate: KSCalendarDelegate? = nil) {
        self._calendar = StateObject(wrappedValue: KSCalendarViewModel(calendarData: calendar,
                                                                       selectedDate: selectedDate,
                                                                       hideMonthView: hideMonthView,
                                                                       hideSecondaryEvent: hideSecondaryEvent,
                                                                       delegate: delegate))
    }
    
    public var body: some View {
        VStack {
            calendarSelection
                .padding()
            calendar(mode: calendar.isDetail)
                .padding(.horizontal)
        }
        .overlay {
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometry.size)
            }
        }
        .onPreferenceChange(SizePreferenceKey.self) {
            calendar.currentSize($0)
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
            .onTapGesture {
                calendar.monthYearToggle()
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
        .foregroundColor(calendar.buttonColor)
    }
    
    @ViewBuilder func calendar(mode month: Bool) -> some View {
        if month {
            if calendar.monthViewIsHidded {
                EmptyView()
            } else {
                KSCalendarMonthGrid(month: calendar.selectedMonth,
                                    year: calendar.selectedYear)
                .gesture(swipeGesture(left: calendar.nextMonth,
                                      right: calendar.previousMonth))
            }
        } else {
            KSCalendarYearGrid()
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
    
    // just for previews
    class PreviewData: KSCalendarData, KSCalendarDataSource {
        struct Item: KSCalendarDayItem {
            let day: Int
            var hasPrimaryEvent: Bool
            var hasSecondaryEvent: Bool

        }
        
        func calendarDayItems(for month: Int, and year: Int) -> [KSCalendarDayItem] {
            return [Item(day: 1,
                            hasPrimaryEvent: true,
                            hasSecondaryEvent: true)]
        }
    }
    
    static var previews: some View {
        KSCalendarView(calendar: PreviewData(), selectedDate: Date())
    }
}

struct SizePreferenceKey: PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
    
}

