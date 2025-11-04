//
//  AttendanceCell.swift
//  MOUP
//
//  Created by 송규섭 on 9/25/25.
//

import UIKit

final class AttendanceCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "AttendanceCell"
    
    // MARK: - UI Function
    func createStackView() -> UIStackView {
        let stackView = UIStackView().then { // 셀의 테두리 영역
            $0.layer.cornerRadius = 12
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.gray400.cgColor
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.isLayoutMarginsRelativeArrangement = true
            $0.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        }
        
        return stackView
    }
    
    // MARK: - UI Components
    private let dateContainer = UIView()
    private let dateView = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
    }
    private let dateLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
    }
    
    private let attendanceContainer = UIView()
    private lazy var attendanceStackView = createStackView()
    private let attendanceLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
        $0.textAlignment = .center
    }
    private let attendanceRightChevron = UIImageView().then {
        $0.image = .attendanceRightChevron
        $0.tintColor = .gray700
    }

    private let leaveWorkContainer = UIView()
    private lazy var leaveWorkStackView = createStackView()
    private let leaveWorkLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
        $0.textAlignment = .center
    }
    private let leaveWorkRightChevron = UIImageView().then {
        $0.image = .attendanceRightChevron
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
    func update(item: AttendanceInfo, userRole: UserRole) {
        dateLabel.text = item.workDate
        // actualStartTime > startTime 우선 순위
        attendanceLabel.text = item.actualStartTime ?? item.startTime
        // actualEndTime > endTime > 빈 문자열 우선 순위
        leaveWorkLabel.text = item.actualEndTime ?? item.endTime ?? "진행 중"
        
        applyUserRole(by: userRole)
    }
}

private extension AttendanceCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        contentView.addSubviews(
            dateContainer,
            stackView
        )
        
        stackView.addArrangedSubviews(
            attendanceContainer,
            leaveWorkContainer
        )
        
        dateContainer.addSubviews(
            dateView
        )
        
        dateView.addSubviews(
            dateLabel
        )
        
        attendanceContainer.addSubviews(
            attendanceStackView
        )
        
        attendanceStackView.addArrangedSubviews(
            attendanceLabel,
            attendanceRightChevron
        )
        
        leaveWorkContainer.addSubviews(
            leaveWorkStackView
        )
        
        leaveWorkStackView.addArrangedSubviews(
            leaveWorkLabel,
            leaveWorkRightChevron
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        contentView.backgroundColor = .primaryBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        dateContainer.snp.makeConstraints {
            $0.directionalVerticalEdges.leading.equalToSuperview()
            $0.width.equalTo(85)
        }
        
        dateView.snp.makeConstraints {
            $0.directionalVerticalEdges.equalToSuperview().inset(6)
            $0.leading.equalToSuperview().inset(13.5)
            $0.width.equalTo(58)
        }
        
        dateLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.directionalVerticalEdges.equalToSuperview().inset(6)
            $0.leading.equalTo(dateContainer.snp.trailing)
            $0.trailing.equalToSuperview()
        }
        
        attendanceStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview().inset(14.5)
            $0.height.equalTo(48)
        }
        
        attendanceRightChevron.snp.makeConstraints {
            $0.width.equalTo(7)
            $0.height.equalTo(12)
        }
        
        leaveWorkStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview().inset(14.5)
            $0.height.equalTo(48)
        }
        
        leaveWorkRightChevron.snp.makeConstraints {
            $0.width.equalTo(7)
            $0.height.equalTo(12)
        }
    }
}

private extension AttendanceCell {
    func applyUserRole(by role: UserRole) {
        // TODO: - 수정 페이지 생기면 역할 별 분기 필요
        attendanceRightChevron.removeFromSuperview()
        leaveWorkRightChevron.removeFromSuperview()
    }
}
