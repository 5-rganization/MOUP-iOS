//
//  TodayRoutineCell.swift
//  MOUP
//
//  Created by 송규섭 on 10/5/25.
//

import UIKit
import SnapKit
import Then

class TodayRoutineCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "TodayRoutineCell"
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
    }
    
    private let workplaceNameLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let routineCountLabel = UILabel().then {
        $0.font = .fieldsRegular(16)
        $0.textColor = .gray700
    }
    
    private let rightIcon = UIImageView().then {
        $0.image = .chevronRightForCard
        $0.tintColor = .gray700
    }

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Public Methods
    func update(with routine: TodayRoutine) {
        workplaceNameLabel.text = routine.workplaceSummary.name
        routineCountLabel.text = "+ \(routine.routineCount)"
    }
}

private extension TodayRoutineCell {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        contentView.addSubviews(
            containerView
        )
        
        containerView.addSubviews(
            rightIcon,
            routineCountLabel,
            workplaceNameLabel
        )
    }
    
    func setStyles() {
        backgroundColor = .primaryBackground
        selectionStyle = .none
    }
    
    func setConstraints() {
        containerView.snp.makeConstraints {
            $0.directionalVerticalEdges.equalToSuperview().inset(6)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
        }
        
        rightIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        routineCountLabel.snp.makeConstraints {
            $0.trailing.equalTo(rightIcon.snp.leading).offset(-12)
            $0.centerY.equalToSuperview()
        }
        
        workplaceNameLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(routineCountLabel.snp.leading)
        }
    }
}
