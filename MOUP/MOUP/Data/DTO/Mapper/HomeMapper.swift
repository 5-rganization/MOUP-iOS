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
                workplace: WorkplaceSummary(
                    id: item.workplaceSummaryInfo.workplaceId,
                    name: item.workplaceSummaryInfo.workplaceName,
                    isShared: item.workplaceSummaryInfo.isShared
                ),
                salary: SalarySummary(
                    type: SalaryType(rawValue: item.salarySummaryInfo.salaryType) ?? .monthly,
                    calculation: SalaryCalculation(rawValue: item.salarySummaryInfo.salaryCalculation) ?? .hourly,
                    hourlyRate: item.salarySummaryInfo.hourlyRate,
                    fixedRate: item.salarySummaryInfo.fixedRate,
                    salaryDate: item.salarySummaryInfo.salaryDate,
                    salaryDay: item.salarySummaryInfo.salaryDay
                ),
                totalWorkMinutes: item.totalWorkMinutes,
                dayTimeMinutes: item.dayTimeMinutes,
                nightTimeMinutes: item.nightTimeMinutes,
                restTimeMinutes: item.restTimeMinutes,
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
                workers: item.monthlyWorkerSummaryInfoList.map(
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
            todayRoutineCount: dto.todayRoutineCounts,
            workplaces: workplaces
        )
        
        return summary
    }
}
