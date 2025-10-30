//
//  SalaryDetailView.swift
//  MOUP
//
//  Created by 송규섭 on 8/13/25.
//

import UIKit
import SnapKit
import Then

final class SalaryDetailView: UIView {
    // MARK: - Properties

    // MARK: - UI Components
    private var salaryDetailRows: [SalaryDetailRowView] = []

    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
    func update(with data: WorkplaceMonthSummary) {
        salaryDetailRows[0].update(title: "총 근무", time: data.totalWorkMinutes.timeString, amount: data.netIncome, isSection: true, showsBottomLine: true)
        salaryDetailRows[1].update(title: "주간", time: data.dayTimeMinutes.timeString, amount: data.dayTimeIncome, isSection: false, showsBottomLine: false)
        salaryDetailRows[2].update(title: "야간", time: data.nightTimeMinutes.timeString, amount: data.totalNightAllowance, isSection: false, showsBottomLine: true)
        salaryDetailRows[3].update(title: "주휴 수당", time: nil, amount: data.totalHolidayAllowance, isSection: true, showsBottomLine: true)
        salaryDetailRows[4].update(title: "4대 보험", time: nil, amount: calculateInsurances(data: data), isSection: true, showsBottomLine: false, showsTime: false)
        salaryDetailRows[5].update(title: "소득세", time: nil, amount: data.incomeTax, isSection: false, showsBottomLine: false)
    }
}

private extension SalaryDetailView {
    // MARK: - configure
    func configure() {
        setupRows()
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        salaryDetailRows.forEach {
            addSubview($0)
        }
    }

    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .clear
        clipsToBounds = true
    }

    // MARK: - setConstraints
    func setConstraints() {
        for (index, row) in salaryDetailRows.enumerated() {
            row.snp.makeConstraints {
                $0.directionalHorizontalEdges.equalToSuperview().inset(24)

                if index == 0 {
                    $0.top.equalToSuperview()
                } else {
                    $0.top.equalTo(salaryDetailRows[index-1].snp.bottom)
                }

                if index == salaryDetailRows.count - 1 {
                    $0.bottom.equalToSuperview()
                }
            }
        }
    }

    // MARK: - setupRows
    func setupRows() {
        salaryDetailRows = [
            .init(title: "총 근무", time: "25시간 07분", amount: 252000, isSection: true, showsBottomLine: true),
            .init(title: "주간", time: "20시간 00분", amount: 200600, isSection: false, showsBottomLine: false),
            .init(title: "야간", time: nil, amount: nil, isSection: false, showsBottomLine: true),
            .init(title: "주휴 수당", time: nil, amount: nil, isSection: true, showsBottomLine: true),
            .init(title: "4대 보험", time: nil, amount: 24947, isSection: true, showsBottomLine: false, showsTime: false),
            .init(title: "소득세", time: nil, amount: 3528, isSection: true, showsBottomLine: false, showsTime: false)
        ]
    }

    /// 4대 보험 세 합산 메서드, 산재보험의 경우 업장마다 달라 조율 필요
    func calculateInsurances(data: WorkplaceMonthSummary) -> Int {
        return (data.nationalPension ?? 0) + (data.healthInsurance ?? 0) + (data.employmentInsurance ?? 0)
    }
}
