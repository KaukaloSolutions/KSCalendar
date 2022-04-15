//
//  EquineIQCalendar.swift
//  EquineIQCalendar
//
//  Created by Janne Jussila on 28.1.2022.
//

import Combine
import UIKit
import SwiftUI


public protocol KSCalendarDelegate: AnyObject {
    func didChangeView(toMonthView: Bool)
    func didChangeDate(to date: Date)
    func didChangeGeometry(to size: CGSize)
}

public extension Notification.Name {
    static var ksCalendar = Notification.Name("KSCalendar")
}

struct DayItem: Identifiable {
    let id: Int
    let day: String?
    var isCurrentDate = false
    var isSelectedDate = false
    var hasPrimaryEvent = false
    var hasSecondaryEvent = false
    
}

class KSCalendarViewModel: ObservableObject {
    
    // MARK: - properties and init()
    
    private let calendar: Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        return calendar
    }()
    
    private weak var delegate: KSCalendarDelegate?
    
    
    @Published private var update = false
    @Published private(set) var monthViewIsHidded: Bool
    private var calendarData: KSCalendarDataSource
    private var cancellables: Set<AnyCancellable> = []
    private var currentDate: Date
    private var selectedDate: Date {
        willSet {
            update.toggle()
            sendDateChange(with: newValue)
        }
    }
    
    
    /// Initialization for CalendarViewModel
    /// - Parameters:
    ///   - calendarData: An object having calendar data inheriting from CalendarData
    ///   - hideMonthView: if monthView needs to be hidden set true, default = false
    ///   - delegate: delegate object conforming to KSCalendarDelegate, default = nil
    init(calendarData: KSCalendarDataSource, hideMonthView: Bool = false, delegate: KSCalendarDelegate? = nil) {
        self.currentDate = calendar.startOfDay(for: Date())
        self.selectedDate = currentDate
        self.calendarData = calendarData
        self.monthViewIsHidded = hideMonthView
        self.delegate = delegate
        setCalendarDataSubscribers()
    }
    
    private func setCalendarDataSubscribers() {
        calendarData.updated
            .receive(on: RunLoop.main)
            .sink { [unowned self] _ in
                self.update.toggle()
            }
            .store(in: &cancellables)
        calendarData.hideMonthView
            .receive(on: RunLoop.main)
            .assign(to: \.monthViewIsHidded, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - API
    private(set) var isDetail = true {
        willSet {
            update.toggle()
            sendIsDetailChange(with: newValue)
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
    
    var textColor: Color { calendarData.textColor }
    
    var buttonColor: Color { calendarData.buttonColor }
    
    var currentDayColor: Color { calendarData.currentDayColor }
    
    var selectedDayColor: Color { calendarData.selectedDayColor }
    
    var primaryEventColor: Color { calendarData.primaryEventColor }
    
    var secondaryEventColor: Color { calendarData.secondaryEventColor }

    func items(for month: Int, and year: Int) -> [DayItem] {
        let calendarDayItems = calendarData.calendarDayItems(for: month, and: year)
        return dayItemsForMonthView(for: month, and: year)
            .map { item in
                guard item.day != nil else { return item }
                var dayItem = item
                if let calendarDayItem = calendarDayItems.first(where: { String($0.day) == dayItem.day }) {
                    dayItem.hasPrimaryEvent = calendarDayItem.hasPrimaryEvent
                    dayItem.hasSecondaryEvent = calendarDayItem.hasSecondaryEvent
                }
                dayItem.isCurrentDate = calendar.isDate(currentDate,
                                                        equalTo: DateComponents(calendar: calendar,
                                                                                timeZone: calendar.timeZone,
                                                                                year: year,
                                                                                month: month,
                                                                                day: Int(dayItem.day!)).date!,
                                                        toGranularity: .day)
                dayItem.isSelectedDate = calendar.isDate(selectedDate,
                                                         equalTo: DateComponents(calendar: calendar,
                                                                                 timeZone: calendar.timeZone,
                                                                                 year: year,
                                                                                 month: month,
                                                                                 day: Int(dayItem.day!)).date!,
                                                         toGranularity: .day)
                return dayItem
            }
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
    
    func currentSize(_ size: CGSize) {
        didChangeGeometry(to: size)
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
    
    private func dayItemsForMonthView(for month: Int, and year: Int) -> [DayItem] {
        let startOfWeekFillDates = startOfWeekFillDates(for: month, and: year)
        let calendarDates = daysRange(for: month, and: year)
            .map { DayItem(id: startOfWeekFillDates.count + $0, day: String($0))}
        return startOfWeekFillDates + calendarDates
    }
    
    private func startOfWeekFillDates(for month: Int, and year: Int) -> [DayItem] {
        (0..<firstDay(on: month, in: year))
            .map { DayItem(id: $0, day: nil) }
    }
    
    private func daysRange(for  month: Int, and year: Int) -> Range<Int> {
        calendar.range(of: .day,
                       in: .month,
                       for: DateComponents(calendar: calendar,
                                           timeZone: calendar.timeZone,
                                           year: year,
                                           month: month,
                                           day: 1).date!)!
    }
    
    private func sendIsDetailChange(with newValue: Bool) {
        delegate?.didChangeView(toMonthView: newValue)
        NotificationCenter.default.post(name: Notification.Name.ksCalendar,
                                        object: self,
                                        userInfo: ["isDetail": newValue])
    }
    
    private func sendDateChange(with date: Date) {
        delegate?.didChangeDate(to: date)
        NotificationCenter.default.post(name: Notification.Name.ksCalendar,
                                        object: self,
                                        userInfo: ["date": date])
    }
    
    private func didChangeGeometry(to size: CGSize) {
        delegate?.didChangeGeometry(to: size)
        NotificationCenter.default.post(name: Notification.Name.ksCalendar,
                                        object: self,
                                        userInfo: ["geometry": size])
    }
    
    
}
