//
//  HomeWorkerResponseDTO.swift
//  MOUP
//
//  Created by 송규섭 on 10/25/25.
//

import Foundation

struct HomeWorkerResponseDTO: Codable {
    let nowMonth: Int
    let totalSalary: Int
    let prevMonthSalaryDiff: Int
    let todayRoutineCounts: Int
    let workerMonthlyWorkplaceSummaryInfoList: [WorkerMonthlyWorkplaceSummaryInfoDTO]
}

struct WorkerMonthlyWorkplaceSummaryInfoDTO: Codable {
    let homeWorkplaceSummaryInfo: HomeWorkplaceSummaryInfoDTO
    let daysUntilPayday: Int?
    let totalWorkMinutes: Int
    let dayTimeMinutes: Int
    let nightTimeMinutes: Int
    let restTimeMinutes: Int
    let dayTimeIncome: Int
    let totalHolidayAllowance: Int?
    let totalNightAllowance: Int?
    let grossIncome: Int
    let nationalPension: Int?
    let healthInsurance: Int?
    let employmentInsurance: Int?
    let incomeTax: Int?
    let netIncome: Int
}

struct HomeWorkplaceSummaryInfoDTO: Codable {
    let workplaceSummaryInfo: WorkplaceSummaryInfoDTO
    let isNowWorking: Bool?
}

struct WorkplaceSummaryInfoDTO: Codable {
    let workplaceId: Int
    let workplaceName: String
    let isShared: Bool
}
