//
//  CalendarData.swift
//  Calendar
//
//  Created by Janne Jussila on 30.3.2022.
//

import Foundation
import Combine


protocol CalendarDataAPI {
    
    func dayItems(for month: Int, and year: Int) -> [CalendarData.CalendarDayItem]
}

open class CalendarData: CalendarDataAPI {
    
    public struct CalendarDayItem {
        let day: Int
        let hasPrimaryEvent: Bool
        let hasSecondaryEvent: Bool
    }
    
    final private let _updated = PassthroughSubject<Void, Never>()
    final var updated: PassthroughSubject<Void, Never> { _updated }
    
    public init() {}
    
    
    // MARK: - API
    func dayItems(for month: Int, and year: Int) -> [CalendarDayItem] {

        return []
    }
    
    
    // MARK: - private methods
    final private func calendarDataHasBeenUpdated() {
        _updated.send()
    }
    
//    private func daysRange(in month: Int, on year: Int) -> Range<Int> {
//        calendar.range(of: .day,
//                       in: .month,
//                       for: DateComponents(calendar: calendar,
//                                           timeZone: calendar.timeZone,
//                                           year: year,
//                                           month: month,
//                                           day: 1).date!)!
//    }
    
}







