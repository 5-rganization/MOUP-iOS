//
//  WorkplaceData.swift
//  MOUP
//
//  Created by 양원식 on 8/4/25.
//

struct WorkplaceData {
    // 근무지 정보
    let name: String
    let category: String
    
    // 급여 정보
    let payType: String
    let payCalculation: String
    let salary: String
    let payDay: String
    
    // 근무 조건
    let nationalPension: Bool
    let healthInsurance: Bool
    let employmentInsurance: Bool
    let industrialAccidentInsurance: Bool
    let incomeTax: Bool
    let weeklyHolidayAllowance: Bool
    let nightShiftAllowance: Bool
    
    // 컬러 라벨
    let colorLabel: String
}
