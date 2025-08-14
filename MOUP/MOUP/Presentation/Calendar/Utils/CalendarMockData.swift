//
//  CalendarMockData.swift
//  MOUP
//
//  Created by 서동환 on 8/14/25.
//

enum CalendarMockData {
    static let calendarEventListMock = (personal: [CalendarEvent(workDate: "2025.08.13", startTime: "09:00", endTime: "19:00", restTime: 60, memo: "개인 근무1", dailyIncome: 90270),
                                                   CalendarEvent(workDate: "2025.08.14", startTime: "12:00", endTime: "18:00", restTime: 30, memo: "개인 근무2", dailyIncome: 55165)],
                                        shared: [CalendarEvent(workDate: "2025.08.25", startTime: "09:00", endTime: "19:00", restTime: 60, memo: "공유 근무1", dailyIncome: 90270),
                                                 CalendarEvent(workDate: "2025.08.26", startTime: "12:00", endTime: "18:00", restTime: 30, memo: "공유 근무2", dailyIncome: 55165)])
}
