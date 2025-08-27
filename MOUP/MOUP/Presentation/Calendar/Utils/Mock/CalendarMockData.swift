//
//  CalendarMockData.swift
//  MOUP
//
//  Created by 서동환 on 8/14/25.
//

enum CalendarMockData {
    static let personalCalendarEventListMock = [CalendarEvent(eventId: 123, workplaceId: 456, workplaceName: "세븐일레븐 동탄제일점", workerId: 789, workerName: "김알바", workDate: "2025.08.14", startTime: "09:00", endTime: "19:00", restTime: 60, memo: "세븐일레븐 근무1", salaryCalculation: .hourly, dailyIncome: 90270, labelColor: "빨간색", isShared: true),
                                                CalendarEvent(eventId: 124, workplaceId: 456, workplaceName: "세븐일레븐 동탄제일점", workerId: 789, workerName: "김알바", workDate: "2025.08.13", startTime: "12:00", endTime: "18:00", restTime: 30, memo: "세븐일레븐 근무2", salaryCalculation: .hourly, dailyIncome: 55165, labelColor: "빨간색", isShared: true),
                                                CalendarEvent(eventId: 125, workplaceId: 135, workplaceName: "쿠팡 동탄1센터", workerId: 789, workerName: "김알바", workDate: "2025.08.25", startTime: "18:00", endTime: "04:00", restTime: 60, memo: "쿠팡 근무1", salaryCalculation: .fixed, dailyIncome: 100000, labelColor: "노란색", isShared: false),
                                                CalendarEvent(eventId: 126, workplaceId: 135, workplaceName: "쿠팡 동탄1센터", workerId: 789, workerName: "김알바", workDate: "2025.08.25", startTime: "18:00", endTime: "04:00", restTime: 60, memo: "쿠팡 근무2", salaryCalculation: .fixed, dailyIncome: 100000, labelColor: "노란색", isShared: false)]
    static let sharedCalendarEventListMock = personalCalendarEventListMock + [CalendarEvent(eventId: 127, workplaceId: 456, workplaceName: "세븐일레븐 동탄제일점", workerId: 780, workerName: "이알바", workDate: "2025.08.25", startTime: "09:00", endTime: "19:00", restTime: 60, memo: "세븐일레븐 동탄제일점 공유 근무1", salaryCalculation: .hourly, dailyIncome: 90270, labelColor: "노란색", isShared: true),
                                                                              CalendarEvent(eventId: 128, workplaceId: 456, workplaceName: "세븐일레븐 동탄제일점", workerId: 780, workerName: "이알바", workDate: "2025.08.26", startTime: "12:00", endTime: "18:00", restTime: 30, memo: "세븐일레븐 동탄제일점 공유 근무2", salaryCalculation: .hourly, dailyIncome: 55165, labelColor: "노란색", isShared: true),
                                                                              CalendarEvent(eventId: 129, workplaceId: 246, workplaceName: "세븐일레븐 동탄중심상가점", workerId: 781, workerName: "박알바", workDate: "2025.08.29", startTime: "12:00", endTime: "18:00", restTime: 30, memo: "세븐일레븐 동탄중심상가점 공유 근무1", salaryCalculation: .hourly, dailyIncome: 55165, labelColor: "파란색", isShared: true),
                                                                              CalendarEvent(eventId: 130, workplaceId: 246, workplaceName: "세븐일레븐 동탄중심상가점", workerId: 782, workerName: "서알바", workDate: "2025.08.29", startTime: "12:00", endTime: "18:00", restTime: 30, memo: "세븐일레븐 동탄중심상가점 공유 근무2", salaryCalculation: .hourly, dailyIncome: 55165, labelColor: "파란색", isShared: true),
                                                                              CalendarEvent(eventId: 131, workplaceId: 246, workplaceName: "세븐일레븐 동탄중심상가점", workerId: 783, workerName: "홍알바", workDate: "2025.08.29", startTime: "18:00", endTime: "00:00", restTime: 30, memo: "세븐일레븐 동탄중심상가점 공유 근무3", salaryCalculation: .hourly, dailyIncome: 55165, labelColor: "남색", isShared: true),
                                                                              CalendarEvent(eventId: 132, workplaceId: 246, workplaceName: "세븐일레븐 동탄중심상가점", workerId: 784, workerName: "최알바", workDate: "2025.08.29", startTime: "18:00", endTime: "00:00", restTime: 30, memo: "세븐일레븐 동탄중심상가점 공유 근무4", salaryCalculation: .hourly, dailyIncome: 55165, labelColor: "남색", isShared: true)]
    static let filterListMock = [FilterWorkplace(workplaceId: 456, workplaceName: "세븐일레븐 동탄제일점", isShared: true),
                                 FilterWorkplace(workplaceId: 135, workplaceName: "쿠팡 동탄1센터", isShared: false),
                                 FilterWorkplace(workplaceId: 246, workplaceName: "세븐일레븐 동탄중심상가점", isShared: true)]
}
