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
    var textColor: Color { get set }
    var currentDayColor: Color { get set }
    var selectedDayColor: Color { get set }
    var buttonColor: Color { get set }
    var primaryEventColor: Color { get set }
    var secondaryEventColor: Color { get set }
}

open class KSCalendarData: KSCalendarColors {
    
    final private let _updated = PassthroughSubject<Void, Never>()
    final public var updated: PassthroughSubject<Void, Never> { _updated }
    final private let _hideMonthView = PassthroughSubject<Bool, Never>()
    final public var hideMonthView: PassthroughSubject<Bool, Never> { _hideMonthView }
    
    // MARK: - KSCalendarColors
    public var textColor: Color = .gray
    public var currentDayColor: Color = .red
    public var selectedDayColor: Color = .purple
    public var buttonColor: Color = .blue
    public var primaryEventColor: Color = .blue
    public var secondaryEventColor: Color = .red
    
    public init() { }
    
    /// Calling this method starts KSCalendarView update. Should be called when calendar data has been updated
    final public func calendarDataHasBeenUpdated() {
        _updated.send()
    }
    
    final public func setMonthViewHidden(_ value: Bool) {
        _hideMonthView.send(value)
    }
    
    
}










