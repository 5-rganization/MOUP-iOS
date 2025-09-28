//
//  ManageAttendanceTableHeaderView.swift
//  MOUP
//
//  Created by 송규섭 on 9/24/25.
//

import UIKit
import SnapKit
import Then

class AttendanceHistoryTableHeaderView: UITableViewHeaderFooterView {
    // MARK: - Properties
    static let identifier = "AttendanceHistoryTableHeaderView"
    
    // MARK: - UI Components
    private let bottomLine = UIView().then {
        $0.backgroundColor = .gray400
    }
    
    private let dateTitleView = UIView()
    private let dateTitleLabel = UILabel().then {
        $0.text = "날짜"
        $0.textColor = .primary600
        $0.font = .buttonSemibold(18)
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.backgroundColor = .primary50
        $0.distribution = .fillEqually
    }
    
    private let attendanceTitleView = UIView()
    private let attendanceTitleLabel = UILabel().then {
        $0.text = "출근"
        $0.textColor = .primary600
        $0.font = .buttonSemibold(18)
    }
    
    private let leaveWorkTitleView = UIView()
    private let leaveWorkTitleLabel = UILabel().then {
        $0.text = "퇴근"
        $0.textColor = .primary600
        $0.font = .buttonSemibold(18)
    }
    
    // MARK: - Initializer
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

}

private extension AttendanceHistoryTableHeaderView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        addSubviews(
            dateTitleView,
            stackView,
            bottomLine
        )
        
        stackView.addArrangedSubviews(
            attendanceTitleView,
            leaveWorkTitleView
        )
        
        dateTitleView.addSubviews(
            dateTitleLabel
        )
        
        attendanceTitleView.addSubviews(
            attendanceTitleLabel
        )
        
        leaveWorkTitleView.addSubviews(
            leaveWorkTitleLabel
        )
    }
    
    func setStyles() {
        [dateTitleView, attendanceTitleView, leaveWorkTitleView].forEach {
            $0.backgroundColor = .primary50
        }
    }
    
    func setConstraints() {
        dateTitleView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(85)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(dateTitleView.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(6)
        }
        
        dateTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        attendanceTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        leaveWorkTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        bottomLine.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(6)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}
