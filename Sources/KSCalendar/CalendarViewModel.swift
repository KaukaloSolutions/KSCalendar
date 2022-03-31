//
//  EquineIQCalendar.swift
//  EquineIQCalendar
//
//  Created by Janne Jussila on 28.1.2022.
//

import Foundation
import Combine


class CalendarViewModel: ObservableObject {
    
    // MARK: - properties and init()
    struct DayItem: Identifiable {
        let id: Int
        let day: String?
        let isCurrentDate: Bool
        let isSelectedDate: Bool
        let hasEvent: Bool
        let hasHealthEvent: Bool
    }
    
    private var calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        return calendar
    }()
    
    @Published private var update = false
    
    private var calendarData: CalendarData
    private var currentDate: Date
    private var selectedDate: Date {
        willSet {
            update.toggle()
        }
    }
    private(set) var monthViewIsHidded: Bool
    private var cancellables: Set<AnyCancellable> = []
    
    /// Initialization for CalendarViewModel
    /// - Parameters:
    ///   - calendarData: An object having calendar data inheriting from CalendarData
    ///   - hideMonthView: if monthView needs to be hidden set true, default = false
    init(calendarData: CalendarData, hideMonthView: Bool = false) {
        self.currentDate = calendar.startOfDay(for: Date())
        self.selectedDate = currentDate
        self.calendarData = calendarData
        self.monthViewIsHidded = hideMonthView
        setCalendarDataSubscriber()
    }
    
    private func setCalendarDataSubscriber() {
        calendarData.updated
            .receive(on: RunLoop.main)
            .sink { [unowned self] _ in
                print("calendar data updated")
                self.update.toggle()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - API
    private(set) var isDetail = true {
        didSet {
            update.toggle()
        }
    }
    
    var title: String {
        isDetail ?
        monthAndYear() :
        String(calendar.component(.year, from: selectedDate))
    }
    
    var weekDays: [String] {
        (0..<7).map { calendar.shortWeekdaySymbols[($0 + calendar.firstWeekday - 1) % 7] }
    }
    
    var months: [String] {
        calendar.shortMonthSymbols
    }
    
    var selectedYear: Int {
        calendar.component(.year, from: selectedDate)
    }
    
    var selectedMonth: Int {
        calendar.component(.month, from: selectedDate)
    }

    func items(for month: Int, and year: Int) -> [DayItem] {
        var calendarItems = fillDates(for: month, and: year)
        calendarItems.append(contentsOf: dayItems(for: month, and: year))
        return calendarItems
    }
    
    func didSelect(day: Int) {
        let selectedDateComponents = calendar.dateComponents(in: calendar.timeZone, from: selectedDate)
        let newDate = DateComponents(calendar: calendar,
                                     timeZone: calendar.timeZone,
                                     year: selectedDateComponents.year,
                                     month: selectedDateComponents.month,
                                     day: day).date!
        selectedDate = calendar.startOfDay(for: newDate)
    }
    
    func didSelect(month: Int, on year: Int) {
        isDetail = true
        let checkDate = calendar.startOfDay(for: DateComponents(calendar: calendar,
                                                                timeZone: calendar.timeZone,
                                                                year: year,
                                                                month: month,
                                                                day: 1).date!)
        if calendar.isDate(currentDate, equalTo: checkDate, toGranularity: .month) {
            selectedDate = currentDate
        } else {
            // Should we give first date of month when in future
            // and last date of month when in past... Get feedback from testers
            // now always 1st date
            selectedDate = checkDate
        }
    }
    
    func nextMonth() {
        setSelectedDate(on: .month, by: 1)
    }
    
    func previousMonth() {
        setSelectedDate(on: .month, by: -1)
    }
    
    func nextYear() {
        setSelectedDate(on: .year, by: 1)
    }
    
    func previousYear() {
        setSelectedDate(on: .year, by: -1)
    }
    
    func monthYearToggle() {
        isDetail.toggle()
    }
    
    
    // MARK: - private methods
    private func setSelectedDate(on component: Calendar.Component, by value: Int) {
        let checkDate = calendar.date(byAdding: component, value: value, to: selectedDate)!
        if calendar.isDate(currentDate, equalTo: checkDate, toGranularity: component) {
            selectedDate = currentDate
        } else {
            let checkDateComponents = calendar.dateComponents(in: calendar.timeZone, from: checkDate)
            selectedDate = calendar.startOfDay(for: DateComponents(calendar: calendar,
                                                                   timeZone: calendar.timeZone,
                                                                   year: checkDateComponents.year,
                                                                   month: checkDateComponents.month,
                                                                   day: 1).date!)
        }
    }
    
    private func firstDay(on month: Int, in year: Int) -> Int {
        let dateComponents = DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: year, month: month)
        guard let date = dateComponents.date else { return 0 }
        let weekDay = calendar.component(.weekday, from: date)
        return (weekDay - calendar.firstWeekday + 7) % 7
    }
    
    
    
    private func monthAndYear() -> String {
        var result = ""
        result.append(calendar.monthSymbols[calendar.component(.month, from: selectedDate) - 1])
        result.append(" \(calendar.component(.year, from: selectedDate))")
        return result
    }
    
    private func fillDates(for month: Int, and year: Int) -> [DayItem] {
        (0..<firstDay(on: month, in: year))
            .map { DayItem(id: $0,
                           day: nil,
                           isCurrentDate: false,
                           isSelectedDate: false,
                           hasEvent: false,
                           hasHealthEvent: false)
            }
    }
    
    private func dayItems(for month: Int, and year: Int) -> [DayItem] {
        
                daysRange(in: month, on: year)
                    .map { DayItem(id: firstDay(on: month, in: year) + $0,
                                   day: String($0),
                                   isCurrentDate: calendar.isDate(currentDate,
                                                                  equalTo: DateComponents(calendar: calendar,
                                                                                          timeZone: calendar.timeZone,
                                                                                          year: year,
                                                                                          month: month,
                                                                                          day: $0).date!,
                                                                  toGranularity: .day),
                                   isSelectedDate: calendar.isDate(selectedDate,
                                                                   equalTo: DateComponents(calendar: calendar,
                                                                                           timeZone: calendar.timeZone,
                                                                                           year: year,
                                                                                           month: month,
                                                                                           day: $0).date!,
                                                                   toGranularity: .day),
                                   hasEvent: true,
                                   hasHealthEvent: $0 % 2 == 1) }
        
        
//        let items = calendarData.dayItems(for: month, and: year)
//        daysRange(in: month, on: year).map {
//
//        }
//        return []
    }
    
    private func daysRange(in month: Int, on year: Int) -> Range<Int> {
        calendar.range(of: .day,
                       in: .month,
                       for: DateComponents(calendar: calendar,
                                           timeZone: calendar.timeZone,
                                           year: year,
                                           month: month,
                                           day: 1).date!)!
    }
    
    
}
