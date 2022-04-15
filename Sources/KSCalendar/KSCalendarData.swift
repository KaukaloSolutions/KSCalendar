//
//  CalendarData.swift
//  Calendar
//
//  Created by Janne Jussila on 30.3.2022.
//

import Foundation
import Combine
import SwiftUI


public protocol KSCalendarDataSource where Self: KSCalendarData {
    // MARK: - API
    ///  A  method to receive all day items for given month  month and year
    /// - Parameters:
    ///   - month: Calendar month 1...12
    ///   - year: Calendar year, for example 2022
    /// - Returns: CalendarDayItems on Array
    func calendarDayItems(for month: Int, and year: Int) -> [KSCalendarDayItem]
}

public protocol KSCalendarDayItem {
    var day: Int { get }
    var hasPrimaryEvent: Bool { get set }
    var hasSecondaryEvent: Bool { get set }
}

public protocol KSCalendarColors {
    var text: Color { get }
    var currentDay: Color { get }
    var selectedDay: Color { get }
    var button: Color { get }
    var primaryEvent: Color { get }
    var secondaryEvent: Color { get }
}

private struct CalendarColors: KSCalendarColors {
    let text = Color.gray
    let currentDay = Color.red
    let selectedDay = Color.purple
    let button = Color.blue
    let primaryEvent = Color.blue
    let secondaryEvent = Color.red
}

open class KSCalendarData {
    
    final private let _updated = PassthroughSubject<Void, Never>()
    final public var updated: PassthroughSubject<Void, Never> { _updated }
    final private let _hideMonthView = PassthroughSubject<Bool, Never>()
    final public var hideMonthView: PassthroughSubject<Bool, Never> { _hideMonthView }
    private(set) var colors: KSCalendarColors
    
    public init(calendarColors: KSCalendarColors? = nil) {
        self.colors = calendarColors ?? CalendarColors()
    }
    
    
    /// Calling this method starts KSCalendarView update. Should be called when calendar data has been updated
    final public func calendarDataHasBeenUpdated() {
        _updated.send()
    }
    
    final public func setMonthViewHidden(_ value: Bool) {
        _hideMonthView.send(value)
    }
        
}










