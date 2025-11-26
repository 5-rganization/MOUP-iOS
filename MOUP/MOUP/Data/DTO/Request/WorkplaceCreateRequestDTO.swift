//
//  WorkplaceCreateRequestDTO.swift
//  MOUP
//
//  Created by 양원식 on 10/30/25.
//

// MARK: - WorkplaceCreateRequest
struct WorkplaceCreateRequestDTO: Codable {
    let workplaceName: String
    let categoryName: String
    let address: String
    let latitude: Double
    let longitude: Double
    let workerBasedLabelColor: String
    let salaryCreateRequest: SalaryCreateRequest
}

// MARK: - SalaryCreateRequest
struct SalaryCreateRequest: Codable {
    let salaryType: String
    let salaryCalculation: String
    let hourlyRate: Int
    let salaryDate: Int
    let hasNationalPension: Bool
    let hasHealthInsurance: Bool
    let hasEmploymentInsurance: Bool
    let hasIndustrialAccident: Bool
    let hasIncomeTax: Bool
    let hasHolidayAllowance: Bool
    let hasNightAllowance: Bool

    // 클라이언트용 생성자 추가
    init(
        salaryType: String,
        salaryCalculation: String,
        hourlyRate: Int,
        salaryDate: Int,
        hasNationalPension: Bool,
        hasHealthInsurance: Bool,
        hasEmploymentInsurance: Bool,
        hasIndustrialAccident: Bool,
        hasIncomeTax: Bool,
        hasHolidayAllowance: Bool,
        hasNightAllowance: Bool
    ) {
        self.salaryType = SalaryType(rawValue: salaryType)?.serverValue ?? salaryType
        self.salaryCalculation = SalaryCalculation(rawValue: salaryCalculation)?.serverValue ?? salaryCalculation
        self.hourlyRate = hourlyRate
        self.salaryDate = salaryDate
        self.hasNationalPension = hasNationalPension
        self.hasHealthInsurance = hasHealthInsurance
        self.hasEmploymentInsurance = hasEmploymentInsurance
        self.hasIndustrialAccident = hasIndustrialAccident
        self.hasIncomeTax = hasIncomeTax
        self.hasHolidayAllowance = hasHolidayAllowance
        self.hasNightAllowance = hasNightAllowance
    }
}

extension SalaryCreateRequest {
    enum SalaryType: String {
        case 매월
        case 매주
        case 매일

        var serverValue: String {
            switch self {
            case .매월: return "SALARY_MONTHLY"
            case .매주: return "SALARY_WEEKLY"
            case .매일: return "SALARY_DAILY"
            }
        }
    }

    enum SalaryCalculation: String {
        case 시급
        case 고정급

        var serverValue: String {
            switch self {
            case .시급: return "SALARY_CALCULATION_HOURLY"
            case .고정급: return "SALARY_CALCULATION_FIXED"
            }
        }
    }
}
