//
//  CalendarData.swift
//  Calendar
//
//  Created by Janne Jussila on 30.3.2022.
//

import Foundation
import Combine


public struct CalendarDayItem {
    let day: Int
    let hasPrimaryEvent: Bool
    let hasSecondaryEvent: Bool
    
    public init(day: Int, hasPrimaryEvent: Bool, hasSecondaryEvent: Bool) {
        self.day = day
        self.hasPrimaryEvent = hasPrimaryEvent
        self.hasSecondaryEvent = hasSecondaryEvent
    }
    
}

open class KSCalendarData {
    
    final private let _updated = PassthroughSubject<Void, Never>()
    final public var updated: PassthroughSubject<Void, Never> { _updated }
    
    public init() {}
    
    
    // MARK: - API
    ///  A  method to receive all day items for given month  month and year
    /// - Parameters:
    ///   - month: Calendar month 1...12
    ///   - year: Calendar year, for example 2022
    /// - Returns: CalendarDayItems on Array
    open func calendarDayItems(for month: Int, and year: Int) -> [CalendarDayItem] {

        return []
    }
    
    /// Calling this method starts KSCalendarView update. Should be called when calendar data has been updated
    final public func calendarDataHasBeenUpdated() {
        _updated.send()
    }
    
}






