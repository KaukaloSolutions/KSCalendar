//
//  CalendarMonthGrid.swift
//  Calendar
//
//  Created by Janne Jussila on 17.1.2022.
//

import SwiftUI

struct KSCalendarMonthGrid: View {
    
    @EnvironmentObject var calendar: KSCalendarViewModel
    var month: Int
    var year: Int
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            weekDays
            dayItems
                .padding(.bottom)
        }
    }
    
    private var weekDays: some View {
        HStack(spacing: 0) {
            ForEach(calendar.weekDays, id: \.self) { weekDay in
                Rectangle()
                    .fill(Color.clear)
                    .aspectRatio(2, contentMode: .fit)
                    .overlay {
                        GeometryReader { geometry in
                            Text(weekDay)
                                .foregroundColor(.gray)
                                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                                .font(.system(size: geometry.size.height * Constants.weekdayFontScale))
                        }
                    }
            }
        }
    }
    
    private var dayItems: some View {
        LazyVGrid(columns: calendarMonthGridItems(), alignment: .center, spacing: 0) {
            ForEach(calendar.items(for: month, and: year)) { item in
                ZStack(alignment: .center) {
                    date(for: item)
                    events(for: item)
                }
                .aspectRatio(1, contentMode: .fill)
                .padding(calendar.isDetail ? 5 : 0)
                .onTapGesture {
                    guard let day = item.day else { return }
                    guard calendar.isDetail else { return }
                    calendar.didSelect(day: Int(day)!)
                }
            }
        }
    }
    
    private func date(for item: DayItem) -> some View {
        Circle()
            .fill(item.isCurrentDate ? Color.red :
                    (item.isSelectedDate && calendar.isDetail) ? .purple :
                    .clear)
            .overlay {
                GeometryReader {geometry in
                    Text(item.day ?? "")
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                        .font(.system(size: geometry.size.width * Constants.fontScale))
                }
            }
    }
    
    private func events(for item: DayItem) -> some View {
        Rectangle()
            .fill(Color.clear)
            .overlay {
                GeometryReader { geometry in
                    HStack(spacing: 2) {
                        eventCircles(for: item)
                    }
                    .scaleEffect(Constants.circleScale)
                    .offset(CGSize(width: 0, height: geometry.size.height / Constants.circleOffset))
                }
            }
    }
    
    // bit dummy way to get always evenly distributed circles
    @ViewBuilder private func eventCircles(for item: DayItem) -> some View {
        if item.hasPrimaryEvent && item.hasSecondaryEvent {
            Circle().foregroundColor(.blue)
            Circle().foregroundColor(.clear)
            Circle().foregroundColor(.red)
        } else if item.hasPrimaryEvent {
            Circle().foregroundColor(.clear)
            Circle().foregroundColor(.blue)
            Circle().foregroundColor(.clear)
        } else if item.hasSecondaryEvent {
            Circle().foregroundColor(.clear)
            Circle().foregroundColor(.red)
            Circle().foregroundColor(.clear)
        } else {
            EmptyView()
        }
    }
    
    private func calendarMonthGridItems() -> [GridItem] {
        var gridItem = GridItem()
        gridItem.spacing = 0
        return (0...6).map { _ in gridItem }
    }
    
    
    private func sizeForDay(in size: CGSize) -> CGSize {
        let width = floor(size.width / CGFloat(7))
        return CGSize(width: width, height: width)
    }
    
}

private struct Constants {
    static let fontScale: CGFloat = 0.5
    static let weekdayFontScale: CGFloat = 0.7
    static let circleScale: CGFloat = 0.4
    static let circleOffset: CGFloat = 3
}


struct CalendarMonthGrid_Previews: PreviewProvider {
    
    struct CalendarMonthGridWrapper: View {
        @StateObject var calendar = KSCalendarViewModel(calendarData: KSCalendarData())
        var body: some View {
            KSCalendarMonthGrid(month: 1, year: 2022)
                .environmentObject(calendar)
        }
    }

    static var previews: some View {
        CalendarMonthGridWrapper()
    }
}
