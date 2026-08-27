//
//  WorkplaceForm.swift
//  MOUP
//
//  Created by 서동환 on 8/27/26.
//

import Foundation

/// 근무지 등록/수정 폼의 상태를 담는 값 타입
///
/// 알바생 직접 등록, 사장님 등록, 초대코드 참여 세 화면이 같은 필드 집합의 부분집합을 쓴다.
/// View에서는 `@State private var form = WorkplaceForm()`으로 선언해 사용한다.
struct WorkplaceForm: Equatable {

    // MARK: - Properties

    var workplaceName: String
    var category: WorkplaceCategory?
    var labelColor: LabelColor

    var salaryType: SalaryType?
    var salaryCalculation: SalaryCalculation?
    /// 시급 또는 고정급 금액. 계산 방식에 따라 `hourlyRate`/`fixedRate` 중 하나로 전송된다.
    var salaryAmount: Int
    /// 급여일(일). 서버의 `salaryDate`.
    var payDay: Int

    var hasNationalPension: Bool
    var hasHealthInsurance: Bool
    var hasEmploymentInsurance: Bool
    var hasIndustrialAccident: Bool
    var hasIncomeTax: Bool
    var hasHolidayAllowance: Bool
    var hasNightAllowance: Bool

    // MARK: - Initializer

    /// 등록 모드: 기본값으로 초기화
    init() {
        self.workplaceName = ""
        self.category = nil
        self.labelColor = ._default
        self.salaryType = nil
        self.salaryCalculation = nil
        self.salaryAmount = 0
        self.payDay = 1
        self.hasNationalPension = false
        self.hasHealthInsurance = false
        self.hasEmploymentInsurance = false
        self.hasIndustrialAccident = false
        self.hasIncomeTax = false
        self.hasHolidayAllowance = false
        self.hasNightAllowance = false
    }

    /// 수정 모드: 상세 응답으로부터 초기화
    ///
    /// 색상 키가 역할에 따라 다르다. 알바생은 `workerBasedLabelColor`, 사장님은 `ownerBasedLabelColor`에만 값이 온다.
    /// 급여 정보(`salaryDetailInfo`)는 알바생일 때만 존재한다.
    init(detail: WorkplaceDetailResponseDTO) {
        self.init()

        self.workplaceName = detail.workplaceName
        self.category = WorkplaceCategory(serverStr: detail.categoryName)

        let colorStr = detail.workerBasedLabelColor ?? detail.ownerBasedLabelColor
        self.labelColor = colorStr.flatMap { LabelColor(serverStr: $0) } ?? ._default

        guard let salary = detail.salaryDetailInfo else { return }

        self.salaryType = SalaryType(serverValue: salary.salaryType)
        self.salaryCalculation = SalaryCalculation(serverValue: salary.salaryCalculation)
        self.salaryAmount = salary.hourlyRate ?? 0
        self.payDay = salary.salaryDate ?? 1
        self.hasNationalPension = salary.hasNationalPension ?? false
        self.hasHealthInsurance = salary.hasHealthInsurance ?? false
        self.hasEmploymentInsurance = salary.hasEmploymentInsurance ?? false
        self.hasIndustrialAccident = salary.hasIndustrialAccident ?? false
        self.hasIncomeTax = salary.hasIncomeTax ?? false
        self.hasHolidayAllowance = salary.hasHolidayAllowance ?? false
        self.hasNightAllowance = salary.hasNightAllowance ?? false
    }
}

// MARK: - 4대 보험

extension WorkplaceForm {

    /// "4대 보험" 마스터 체크박스의 표시 상태
    ///
    /// 별도 필드로 저장하지 않는다. 하위 4개가 모두 켜졌는지의 파생 값이다.
    var hasAllMajorInsurances: Bool {
        hasNationalPension && hasHealthInsurance && hasEmploymentInsurance && hasIndustrialAccident
    }

    /// "4대 보험" 마스터 체크박스를 탭했을 때 하위 4개를 일괄 설정한다.
    mutating func setAllMajorInsurances(_ isOn: Bool) {
        hasNationalPension = isOn
        hasHealthInsurance = isOn
        hasEmploymentInsurance = isOn
        hasIndustrialAccident = isOn
    }
}

// MARK: - 표시용 파생 값

extension WorkplaceForm {

    var formattedSalaryAmount: String {
        salaryAmount == 0 ? "선택" : NumberFormatter.formattedWon(from: salaryAmount)
    }

    var formattedPayDay: String {
        "\(payDay)일"
    }
}

// MARK: - 유효성

extension WorkplaceForm {

    /// 알바생 직접 등록/수정: 근무지 · 급여가 모두 필요하다.
    var isWorkerValid: Bool {
        !workplaceName.isEmpty
            && category != nil
            && salaryType != nil
            && salaryCalculation != nil
            && salaryAmount > 0
    }

    /// 사장님 등록/수정: 근무지 정보만 받는다.
    var isOwnerValid: Bool {
        !workplaceName.isEmpty && category != nil
    }

    /// 초대코드 참여: 이름·카테고리는 초대코드가 결정하므로 검사하지 않는다.
    var isJoinValid: Bool {
        salaryType != nil && salaryCalculation != nil && salaryAmount > 0
    }
}

// MARK: - DTO 변환

extension WorkplaceForm {

    /// 시급제면 `hourlyRate`에, 고정급이면 `fixedRate`에 금액이 들어간다.
    private var isHourly: Bool {
        salaryCalculation == .hourly
    }

    /// 알바생 직접 등록 요청 DTO
    ///
    /// 주소·좌표는 화면에 입력 수단이 없어 기존 UIKit 구현과 동일한 더미값을 보낸다.
    var createRequestDTO: WorkplaceCreateRequestDTO {
        WorkplaceCreateRequestDTO(
            workplaceName: workplaceName,
            categoryName: (category ?? .others).serverStr,
            address: "기본 주소",
            latitude: 0.0,
            longitude: 0.0,
            workerBasedLabelColor: labelColor.serverStr,
            salaryCreateRequest: salaryCreateRequest
        )
    }

    /// 사장님 등록 요청 DTO
    ///
    /// 색상 키가 알바생과 다르다. 사장님은 `ownerBasedLabelColor`다.
    var ownerCreateRequestDTO: OwnerWorkplaceCreateRequestDTO {
        OwnerWorkplaceCreateRequestDTO(
            workplaceName: workplaceName,
            categoryName: (category ?? .others).serverStr,
            ownerBasedLabelColor: labelColor.serverStr
        )
    }

    /// 알바생 근무지 수정 요청 DTO
    ///
    /// `UpdateWorkplaceRequestDTO`는 색상 키를 역할별로 나눠 갖고(둘 중 하나만 채운다),
    /// `salaryUpdateRequest`는 알바생일 때만 필요하다. 사장님용과 반드시 구분해서 써야 한다.
    var workerUpdateRequestDTO: UpdateWorkplaceRequestDTO {
        UpdateWorkplaceRequestDTO(
            workplaceName: workplaceName,
            categoryName: (category ?? .others).serverStr,
            address: "기본 주소",
            latitude: 0.0,
            longitude: 0.0,
            workerBasedLabelColor: labelColor.serverStr,
            salaryUpdateRequest: SalaryUpdateRequestDTO(
                salaryType: (salaryType ?? .monthly).serverValue,
                salaryCalculation: (salaryCalculation ?? .hourly).serverValue,
                hourlyRate: salaryAmount,
                salaryDate: payDay,
                hasNationalPension: hasNationalPension,
                hasHealthInsurance: hasHealthInsurance,
                hasEmploymentInsurance: hasEmploymentInsurance,
                hasIndustrialAccident: hasIndustrialAccident,
                hasIncomeTax: hasIncomeTax,
                hasHolidayAllowance: hasHolidayAllowance,
                hasNightAllowance: hasNightAllowance
            )
        )
    }

    /// 사장님 근무지 수정 요청 DTO
    ///
    /// 사장님 화면에는 급여 입력이 없으므로 `salaryUpdateRequest`를 보내지 않는다.
    /// 색상은 `ownerBasedLabelColor`로 보낸다 — 알바생 키로 보내면 색상이 반영되지 않는다.
    var ownerUpdateRequestDTO: UpdateWorkplaceRequestDTO {
        UpdateWorkplaceRequestDTO(
            workplaceName: workplaceName,
            categoryName: (category ?? .others).serverStr,
            address: "기본 주소",
            latitude: 0.0,
            longitude: 0.0,
            ownerBasedLabelColor: labelColor.serverStr
        )
    }

    /// 초대코드 참여 요청 DTO
    ///
    /// 참여 전용 DTO만 `fixedRate`·`salaryDay`를 갖는다. 직접 등록용 `SalaryCreateRequest`에는 없다.
    /// `salaryDay`는 화면에 입력 수단이 없어 기존 UIKit 구현과 동일하게 `"MONDAY"`를 보낸다.
    func joinRequestDTO(inviteCode: String) -> WorkplaceJoinRequestDTO {
        WorkplaceJoinRequestDTO(
            inviteCode: inviteCode,
            workerBasedLabelColor: labelColor.serverStr,
            salaryCreateRequest: SalaryJoinCreateRequest(
                salaryType: (salaryType ?? .monthly).serverValue,
                salaryCalculation: (salaryCalculation ?? .hourly).serverValue,
                hourlyRate: isHourly ? salaryAmount : nil,
                fixedRate: isHourly ? nil : salaryAmount,
                salaryDate: payDay,
                salaryDay: "MONDAY",
                hasNationalPension: hasNationalPension,
                hasHealthInsurance: hasHealthInsurance,
                hasEmploymentInsurance: hasEmploymentInsurance,
                hasIndustrialAccident: hasIndustrialAccident,
                hasIncomeTax: hasIncomeTax,
                hasHolidayAllowance: hasHolidayAllowance,
                hasNightAllowance: hasNightAllowance
            )
        )
    }

    private var salaryCreateRequest: SalaryCreateRequest {
        SalaryCreateRequest(
            salaryType: (salaryType ?? .monthly).serverValue,
            salaryCalculation: (salaryCalculation ?? .hourly).serverValue,
            hourlyRate: salaryAmount,
            salaryDate: payDay,
            hasNationalPension: hasNationalPension,
            hasHealthInsurance: hasHealthInsurance,
            hasEmploymentInsurance: hasEmploymentInsurance,
            hasIndustrialAccident: hasIndustrialAccident,
            hasIncomeTax: hasIncomeTax,
            hasHolidayAllowance: hasHolidayAllowance,
            hasNightAllowance: hasNightAllowance
        )
    }
}
