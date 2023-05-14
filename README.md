# KSCalendar

A SwiftUI calendar with similar look as DatePicker. Allows selection of date and has both month and year views. Each day can have two individual event types to be shown.

A subclass from KSCalendarData is needed to show dayitems on calendar. Whenever calendar data is updated function calendarDataHasBeenUpdated() needs to be called on subclass.

Also subclass should override default implementation of func dayItems(for:and:) -> [CalendarDayiItem] allowing Calendar to show if there are events on calendar for specific days.
