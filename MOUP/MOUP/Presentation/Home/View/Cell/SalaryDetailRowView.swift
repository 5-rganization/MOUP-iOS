//
//  SalaryDetailRowView.swift
//  MOUP
//
//  Created by 송규섭 on 8/18/25.
//

import UIKit

final class SalaryDetailRowView: UIView {
    // MARK: - Properties
    private let title: String
    private let time: String?
    private let amount: Int? // TODO: - NumberFormatter 적용
    private let showsBottomLine: Bool
    private let isSection: Bool
    private let showsTime: Bool

    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textColor = .gray900
    }

    private let timeLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textColor = .gray900
        $0.textAlignment = .right
    }

    private let amountLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textColor = .gray900
        $0.textAlignment = .right
    }

    private let bottomLine = UIView().then {
        $0.backgroundColor = .gray300
    }

    // MARK: - Initializer
    init(title: String, time: String?, amount: Int?, isSection: Bool, showsBottomLine: Bool, showsTime: Bool = true) {
        self.title = title
        self.time = time
        self.amount = amount
        self.isSection = isSection
        self.showsBottomLine = showsBottomLine
        self.showsTime = showsTime
        super.init(frame: .zero)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
}

private extension SalaryDetailRowView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        applyData()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            titleLabel,
            timeLabel,
            amountLabel,
            bottomLine
        )
    }

    // MARK: - setStyles
    func setStyles() {
        bottomLine.isHidden = !showsBottomLine
        timeLabel.isHidden = !showsTime
        if isSection {
            [titleLabel, timeLabel, amountLabel].forEach {
                $0.font = .headBold(12)
            }
            bottomLine.backgroundColor = .gray700
        }
    }

    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.directionalVerticalEdges.equalToSuperview().inset(4)
        }

        amountLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalTo(titleLabel)
            $0.width.equalTo(77.5)
        }

        timeLabel.snp.makeConstraints {
            $0.trailing.equalTo(amountLabel.snp.leading).offset(-12)
            $0.centerY.equalTo(titleLabel)
            $0.width.equalTo(77.5)
        }

        bottomLine.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func applyData() {
        titleLabel.text = title
        timeLabel.text = time ?? "-"
        if let amount {
            amountLabel.text = NumberFormatter.formattedWon(from: String(amount))
        } else {
            amountLabel.text = "-"
        }
    }
}

