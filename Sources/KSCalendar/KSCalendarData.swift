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

public struct KSCalendarColors {
    let text: Color
    let currentDay: Color
    let selectedDay: Color
    let button: Color
    let primaryEvent: Color
    let secondaryEvent: Color
    
    public init(text: Color = .gray, currentDay: Color = .red, selectedDay: Color = .purple, button: Color = .blue, primaryEvent: Color = .blue, secondaryEvent: Color = .red) {
        self.text = text
        self.currentDay = currentDay
        self.selectedDay = selectedDay
        self.button = button
        self.primaryEvent = primaryEvent
        self.secondaryEvent = secondaryEvent
    }
}

open class KSCalendarData {
    
    final private let _updated = PassthroughSubject<Void, Never>()
    final public var updated: PassthroughSubject<Void, Never> { _updated }
    final private let _hideMonthView = PassthroughSubject<Bool, Never>()
    final public var hideMonthView: PassthroughSubject<Bool, Never> { _hideMonthView }
    final let colors: KSCalendarColors
    
    public init(calendarColors: KSCalendarColors? = nil) {
        self.colors = calendarColors ?? KSCalendarColors()
    }
    
    
    /// Calling this method starts KSCalendarView update. Should be called when calendar data has been updated
    final public func calendarDataHasBeenUpdated() {
        _updated.send()
    }
    
    final public func setMonthViewHidden(_ value: Bool) {
        _hideMonthView.send(value)
    }
        
}










