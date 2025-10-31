//
//  RoutineListCell.swift
//  MOUP
//
//  Created by 송규섭 on 10/5/25.
//

import UIKit
import SnapKit
import Then

class RoutineListCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "RoutineListCell"
    
    // MARK: - UI Components
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let alarmTimeLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
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
    func update(with routine: RoutineSummary) {
        titleLabel.text = routine.routineName
        alarmTimeLabel.text = routine.alarmTime ?? ""
    }
    
}

private extension RoutineListCell {
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
            titleLabel,
            alarmTimeLabel,
            rightIcon
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
        
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        alarmTimeLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(rightIcon.snp.leading)
        }
        
        rightIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
}
