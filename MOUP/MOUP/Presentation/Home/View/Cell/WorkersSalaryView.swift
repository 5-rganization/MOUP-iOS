//
//  WorkersSalaryView.swift
//  MOUP
//
//  Created by 송규섭 on 9/9/25.
//

import UIKit
import SnapKit
import Then

final class WorkersSalaryView: UIView {
    // MARK: - UI Components
    private let stackView = UIStackView().then {
        $0.axis = .vertical
    }

    private let firstRow = SalaryDetailRowView(
        title: "총 인건비",
        time: "25시간 07분",
        amount: 252000,
        isSection: true,
        showsBottomLine: true,
        showsTime: true
    )

    // MARK: - Initializer
    init() {
        super.init(frame: .zero)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
    func update(with workSummaries: [MonthlyWorkerSummary]) {
        var totalWorkMinutes = 0
        var totalAmount = 0
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stackView.addArrangedSubview(firstRow)
        workSummaries.enumerated().forEach { index, summary in
            totalWorkMinutes += summary.totalWorkMinutes
            totalAmount += summary.netIncome
            let isLastRow = index == workSummaries.count - 1
            let row = SalaryDetailRowView(
                title: summary.nickname,
                time: summary.totalWorkMinutes.timeString,
                amount: summary.netIncome,
                isSection: false,
                showsBottomLine: !isLastRow
            )
            stackView.addArrangedSubview(row)
        }
        firstRow.update(
            title: "총 인건비",
            time: totalWorkMinutes.timeString,
            amount: totalAmount,
            isSection: true,
            showsBottomLine: true
        )
    }
}

private extension WorkersSalaryView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            stackView
        )
    }

    // MARK: - setStyles
    func setStyles() {

    }

    // MARK: - setConstraints
    func setConstraints() {
        stackView.snp.makeConstraints {
            $0.directionalVerticalEdges.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview().inset(24)
        }
    }

}

