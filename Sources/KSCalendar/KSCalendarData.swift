//
//  CalendarData.swift
//  Calendar
//
//  Created by Janne Jussila on 30.3.2022.
//

import Foundation
import Combine


public protocol KSCalendarDataSource where Self: KSCalendarData {
    // MARK: - API
    ///  A  method to receive all day items for given month  month and year
    /// - Parameters:
    ///   - month: Calendar month 1...12
    ///   - year: Calendar year, for example 2022
    /// - Returns: CalendarDayItems on Array
    func calendarDayItems(for month: Int, and year: Int) -> [KSCalendarDayItem]
}


public struct KSCalendarDayItem {
    let day: Int
    public var hasPrimaryEvent: Bool
    public var hasSecondaryEvent: Bool
    
    public init(day: Int, hasPrimaryEvent: Bool = false, hasSecondaryEvent: Bool = false) {
        self.day = day
        self.hasPrimaryEvent = hasPrimaryEvent
        self.hasSecondaryEvent = hasSecondaryEvent
    }
    
}

open class KSCalendarData {
    
    final private let _updated = PassthroughSubject<Void, Never>()
    final public var updated: PassthroughSubject<Void, Never> { _updated }
    final private let _hideMonthView = PassthroughSubject<Bool, Never>()
    final public var hideMonthView: PassthroughSubject<Bool, Never> { _hideMonthView }
    
    public init() {}
    
    
    /// Calling this method starts KSCalendarView update. Should be called when calendar data has been updated
    final public func calendarDataHasBeenUpdated() {
        _updated.send()
    }
    
    final public func setMonthViewHidden(_ value: Bool) {
        _hideMonthView.send(value)
    }
        
}







