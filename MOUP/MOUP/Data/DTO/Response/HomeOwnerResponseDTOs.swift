//
//  HomeOwnerResponseDTO.swift
//  MOUP
//
//  Created by 송규섭 on 10/25/25.
//

import Foundation

struct HomeOwnerResponseDTO: Decodable {
    let nowMonth: Int
    let totalSalary: Int
    let prevMonthSalaryDiff: Int
    let todayRoutineCounts: Int
    let ownerMonthlyWorkplaceSummaryInfoList: [OwnerMonthlyWorkplaceSummaryInfoDTO]
}

struct OwnerMonthlyWorkplaceSummaryInfoDTO: Decodable {
    let workplaceSummaryInfo: WorkplaceSummaryInfoDTO
    let monthlyWorkerSummaryInfoList: [MonthlyWorkerSummaryInfoDTO]
}

struct MonthlyWorkerSummaryInfoDTO: Decodable {
    let nickname: String
    let totalWorkMinutes: Int
    let grossIncome: Int
    let netIncome: Int
}
