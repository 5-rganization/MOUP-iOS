//
//  HomeMapper.swift
//  MOUP
//
//  Created by 송규섭 on 10/27/25.
//

import Foundation

struct HomeMapper {
    func mapToWorkerSummary(_ dto: HomeWorkerResponseDTO) -> HomeWorkerSummary {
        let workplaces = dto.workerMonthlyWorkplaceSummaryInfoList.map { item in
            WorkplaceMonthSummary(
                homeWorkplace: HomeWorkplaceSummary(
                    workplace: WorkplaceSummary(
                        id: item.homeWorkplaceSummaryInfo.workplaceSummaryInfo.workplaceId,
                        name: item.homeWorkplaceSummaryInfo.workplaceSummaryInfo.workplaceName,
                        isShared: item.homeWorkplaceSummaryInfo.workplaceSummaryInfo.isShared
                    ),
                    isNowWorking: item.homeWorkplaceSummaryInfo.isNowWorking
                ),
                daysUntilPayday: item.daysUntilPayday,
                totalWorkMinutes: item.totalWorkMinutes,
                dayTimeMinutes: item.dayTimeMinutes,
                nightTimeMinutes: item.nightTimeMinutes,
                restTimeMinutes: item.restTimeMinutes,
                dayTimeIncome: item.dayTimeIncome,
                totalHolidayAllowance: item.totalHolidayAllowance,
                totalNightAllowance: item.totalNightAllowance,
                grossIncome: item.grossIncome,
                nationalPension: item.nationalPension,
                healthInsurance: item.healthInsurance,
                employmentInsurance: item.employmentInsurance,
                incomeTax: item.incomeTax,
                netIncome: item.netIncome
            )
        }
        
        let summary = HomeWorkerSummary(
            month: dto.nowMonth,
            totalSalary: dto.totalSalary,
            prevMonthSalaryDiff: dto.prevMonthSalaryDiff,
            todayRoutineCount: dto.todayRoutineCounts,
            workplaces: workplaces
        )
        
        return summary
    }
    
    func mapToOwnerSummary(_ dto: HomeOwnerResponseDTO) -> HomeOwnerSummary {
        let workplaces = dto.ownerMonthlyWorkplaceSummaryInfoList.map { item in
            OwnerMonthlyWorkplaceSummary(
                workplace: WorkplaceSummary(
                    id: item.workplaceSummaryInfo.workplaceId,
                    name: item.workplaceSummaryInfo.workplaceName,
                    isShared: item.workplaceSummaryInfo.isShared
                ),
                workerSummaries: item.monthlyWorkerSummaryInfoList.map(
                    { dto in
                        MonthlyWorkerSummary(
                            nickname: dto.nickname,
                            totalWorkMinutes: dto.totalWorkMinutes,
                            grossIncome: dto.grossIncome,
                            netIncome: dto.netIncome
                        )
                    })
            )
        }
        
        let summary = HomeOwnerSummary(
            month: dto.nowMonth,
            totalSalary: dto.totalSalary,
            prevMonthSalaryDiff: dto.prevMonthSalaryDiff,
            todayRoutineCount: dto.todayRoutineCounts,
            workplaces: workplaces
        )
        
        return summary
    }
}
