//
//  CalendarMockData.swift
//  MOUP
//
//  Created by 서동환 on 8/14/25.
//

enum CalendarMockData {
    static let personalCalendarEventListMock = [CalendarEvent(eventId: 123, workplaceId: 456, workplaceName: "세븐일레븐 동탄제일점", workerId: 789, workerName: "김알바", workDate: "2025.08.13", startTime: "09:00", endTime: "19:00", restTime: 60, memo: "세븐일레븐 근무1", dailyIncome: 90270, colorLabel: "빨간색"),
                                                CalendarEvent(eventId: 124, workplaceId: 456, workplaceName: "세븐일레븐 동탄제일점", workerId: 789, workerName: "김알바", workDate: "2025.08.14", startTime: "12:00", endTime: "18:00", restTime: 30, memo: "세븐일레븐 근무2", dailyIncome: 55165, colorLabel: "빨간색"),
                                                CalendarEvent(eventId: 125, workplaceId: 135, workplaceName: "쿠팡 동탄1센터", workerId: 789, workerName: "김알바", workDate: "2025.08.25", startTime: "18:00", endTime: "04:00", restTime: 60, memo: "쿠팡 근무1", dailyIncome: 90270, colorLabel: "노란색"),
                                                CalendarEvent(eventId: 126, workplaceId: 135, workplaceName: "쿠팡 동탄1센터", workerId: 789, workerName: "김알바", workDate: "2025.08.25", startTime: "18:00", endTime: "04:00", restTime: 60, memo: "쿠팡 근무2", dailyIncome: 90270, colorLabel: "노란색")]
    static let sharedCalendarEventListMock = personalCalendarEventListMock + [CalendarEvent(eventId: 127, workplaceId: 456, workplaceName: "세븐일레븐 동탄제일점", workerId: 780, workerName: "이알바", workDate: "2025.08.25", startTime: "09:00", endTime: "19:00", restTime: 60, memo: "세븐일레븐 공유 근무1", dailyIncome: 90270, colorLabel: "노란색"),
                                                                              CalendarEvent(eventId: 128, workplaceId: 456, workplaceName: "세븐일레븐 동탄제일점", workerId: 780, workerName: "이알바", workDate: "2025.08.26", startTime: "12:00", endTime: "18:00", restTime: 30, memo: "세븐일레븐 공유 근무2", dailyIncome: 55165, colorLabel: "노란색")]
    static let filterListMock = [FilterWorkplace(workplaceId: 456, workplaceName: "세븐일레븐 동탄제일점"), FilterWorkplace(workplaceId: 135, workplaceName: "쿠팡 동탄1센터")]
}
