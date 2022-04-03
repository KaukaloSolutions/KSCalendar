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
        GeometryReader { geometry in
            VStack {
                weekDays(with: geometry)
                dayItems(with: geometry)
            }
        }
    }
    
    private func weekDays(with geometry: GeometryProxy) -> some View {
        HStack(spacing: 0) {
            ForEach(calendar.weekDays, id: \.self) { weekDay in
                Text(weekDay)
                    .frame(width: geometry.size.width / CGFloat(7))
                    .font(.system(size: geometry.size.width / CGFloat(7) * Constants.weekdayFontScale))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: geometry.size.width, alignment: .center)
    }
    
    // not really needed as ViewBuilder, but easier to understand idea
    @ViewBuilder private func dayItems(with geometry: GeometryProxy) -> some View {
        let size = sizeForDay(in: geometry.size)
        LazyVGrid(columns: [calendarMonthGridItem(for: size)],
                  alignment: .center,
                  spacing: 0) {
            ForEach(calendar.items(for: month, and: year)) { item in
                VStack(alignment: .center, spacing: 0) {
                    date(for: item, using: size)
                    events(for: item, using: size)
                }
                .frame(width: size.width, height: size.height, alignment:  .center)
                .onTapGesture {
                    guard let day = item.day else { return }
                    guard calendar.isDetail else { return }
                    calendar.didSelect(day: Int(day)!)
                }
            }
        }
    }
    
    private func date(for item: DayItem, using size: CGSize) -> some View {
        ZStack {
            Group {
                if(item.isCurrentDate) {
                    Circle()
                        .fill((Color.red))
                } else if(item.isSelectedDate && calendar.isDetail) {
                    Circle()
                        .fill(Color.purple)
                }
            }
            .frame(width: size.width * Constants.dayCirclePaddingScale,
                   height: size.height * Constants.dayCirclePaddingScale,
                   alignment: .center)
            Text(item.day ?? "")
                .font(.system(size: size.width * Constants.fontScale))
        }
    }
    
    private func events(for item: DayItem, using size: CGSize) -> some View {
        HStack(alignment: .bottom, spacing: 2) {
            Spacer()
            if(item.hasPrimaryEvent) {
                Circle()
                    .frame(width: size.width * Constants.circleScale, height: size.height  * Constants.circleScale, alignment: .center)
                    .foregroundColor(.blue)
            }
            if(item.hasSecondaryEvent) {
                Circle()
                    .frame(width: size.width * Constants.circleScale, height: size.height  * Constants.circleScale, alignment: .center)
                    .foregroundColor(.red)
            }
            Spacer()
        }
    }
    
    private func calendarMonthGridItem(for size: CGSize) -> GridItem {
        var gridItem = GridItem(.adaptive(minimum: size.width, maximum: size.width))
        gridItem.spacing = 0
        return gridItem
    }
    
    private func sizeForDay(in size: CGSize) -> CGSize {
        let width = floor(size.width / CGFloat(7))
        return CGSize(width: width, height: width)
    }
    
}

private struct Constants {
    static let padScale: CGFloat = 30
    static let fontScale: CGFloat = 0.35
    static let dayCirclePaddingScale: CGFloat = 0.5
    static let gridVerticalSpacingScale: CGFloat = 0
    static let circleScale: CGFloat = 0.1
    static let weekdayFontScale: CGFloat = 0.27
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
