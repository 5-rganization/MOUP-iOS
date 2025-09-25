//
//  AttendanceCell.swift
//  MOUP
//
//  Created by 송규섭 on 9/25/25.
//

import UIKit

class AttendanceCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "AttendanceCell"
    
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
    private let attendanceView = UIView().then { // 셀의 테두리 영역
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
    }
    private let attendanceInternalView = UIView() // 레이블과 우측 화살표를 고정할 영역
    private let attendanceLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    private let attendanceRightChevron = UIImageView().then {
        $0.image = .attendanceRightChevron
        $0.tintColor = .gray700
    }

    private let leaveWorkContainer = UIView()
    private let leaveWorkView = UIView().then { // 셀의 테두리 영역
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
    }
    private let leaveWorkInternalView = UIView() // 레이블과 우측 화살표를 고정할 영역
    private let leaveWorkLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
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
    func update(item: AttendanceData) {
        dateLabel.text = item.date
        attendanceLabel.text = item.attendanceTime
        leaveWorkLabel.text = item.leaveWorkTime
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
            attendanceView
        )
        
        attendanceView.addSubviews(
            attendanceInternalView
        )
        
        attendanceInternalView.addSubviews(
            attendanceLabel,
            attendanceRightChevron
        )
        
        leaveWorkContainer.addSubviews(
            leaveWorkView
        )
        
        leaveWorkView.addSubviews(
            leaveWorkInternalView
        )
        
        leaveWorkInternalView.addSubviews(
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
        
        attendanceView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview().inset(14.5)
            $0.height.equalTo(48)
        }
        
        attendanceInternalView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(84)
            $0.height.equalTo(24) // TODO: - 해당 프레임 size를 고정할지, 좌우 크기에 맞춰 넓힐지.
        }
        
        attendanceRightChevron.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.width.equalTo(7)
            $0.height.equalTo(12)
        }
        
        attendanceLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(attendanceRightChevron.snp.leading)
        }
        
        leaveWorkView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview().inset(14.5)
            $0.height.equalTo(48)
        }
        
        leaveWorkInternalView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(84)
            $0.height.equalTo(24)
        }
        
        leaveWorkRightChevron.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.width.equalTo(7)
            $0.height.equalTo(12)
        }
        
        leaveWorkLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(leaveWorkRightChevron.snp.leading)
        }
    }
}
