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
    // MARK: - UI Components
    private let stackView = UIStackView().then {
        $0.axis = .vertical
    }
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
        addSubviews(stackView)
        salaryDetailRows.forEach {
            stackView.addArrangedSubview($0)
        }

        print("스택뷰의 개수: \(stackView.arrangedSubviews.count)")
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

    // MARK: - setupRows
    func setupRows() {
        salaryDetailRows = [
            .init(title: "총 근무", time: "25시간 07분", amount: 252000, isSection: true, showsBottomLine: true),
            .init(title: "주간", time: "20시간 00분", amount: 200600, isSection: false, showsBottomLine: false),
            .init(title: "야간", time: nil, amount: nil, isSection: false, showsBottomLine: true),
            .init(title: "대타 근무", time: "05시간 07분", amount: 51344, isSection: true, showsBottomLine: false),
            .init(title: "주간", time: "05시간 07분", amount: 51344, isSection: false, showsBottomLine: false),
            .init(title: "야간", time: nil, amount: nil, isSection: false, showsBottomLine: true),
            .init(title: "주휴 수당", time: nil, amount: nil, isSection: true, showsBottomLine: true),
            .init(title: "4대 보험", time: nil, amount: 24947, isSection: true, showsBottomLine: false, showsTime: false),
            .init(title: "소득세", time: nil, amount: 3528, isSection: true, showsBottomLine: false, showsTime: false)
        ]
    }
}
