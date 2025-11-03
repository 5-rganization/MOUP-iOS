//
//  CalendarDayCell.swift
//  MOUP
//
//  Created by 서동환 on 7/21/25.
//

import UIKit

import JTAppleCalendar
import SnapKit
import Then

/// 캘린더 내부 날짜 셀
final class CalendarDayCell: JTACDayCell {
    
    // MARK: - Properties
    static let identifier = String(describing: CalendarDayCell.self)
    
    // MARK: - UI Components
    /// 구분선
    private let seperatorView = UIView().then {
        $0.backgroundColor = .gray300
    }
    /// 선택됐을 때 표시되는 UI
    private let selectedView = UIView().then {
        $0.backgroundColor = .primary50
        $0.isHidden = true
    }
    /// 날짜(일) 라벨
    private let dayLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(14)
        $0.textAlignment = .center
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    /// 근무 컨테이너 UI
    private let workContainerVStackView = WorkContainerVStackView()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // workContainerVStackView의 minY 계산
        let workContainerMinY = dayLabel.frame.maxY + 4
        
        // workContainerVStackView의 너비 계산
        let targetWidth = self.contentView.bounds.width - 4
        // systemLayoutSizeFitting에 전달할 목표 크기 계산 - 너비는 targetWidth, 높이는 시스템이 계산
        let targetSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        // targetSize를 이용하여 workContainerVStackView의 잠재적인 최대 높이 계산
        let requiredHeight = workContainerVStackView.systemLayoutSizeFitting(targetSize,
                                                                             withHorizontalFittingPriority: .required,
                                                                             verticalFittingPriority: .fittingSizeLevel).height
        // workContainerVStackView의 잠재적인 maxY 계산
        let potentialMaxY = workContainerMinY + requiredHeight
        
        // workContainerVStackView의 최대 maxY 계산(여백 4 포함)
        let possibleMaxY = self.contentView.bounds.height - 4
        
        // 근무 컨테이너 UI가 캘린더 셀을 벗어나거나 여백이 4 미만일 때
        if potentialMaxY >= possibleMaxY {
            let possibleMaxHeight = possibleMaxY - workContainerMinY
            let reducedCount = Int(possibleMaxHeight / (WorkRowSize.baseComponentHeight + workContainerVStackView.spacing))
            // 근무 UI 크기 줄임
            workContainerVStackView.reduceHeight(displayCount: reducedCount)
        }
    }
    
    // MARK: - Internal Methods
    func update(dateStr: String, isToday: Bool, daysOfWeek: DaysOfWeek, dateBelongsToThisMonth: Bool, isSelected: Bool, calendarMode: CalendarMode, workList: [WorkSummary]) {
        dayLabel.text = dateStr
        
        if isToday {
            dayLabel.textColor = .white
            dayLabel.backgroundColor = .gray900
        } else {
            switch daysOfWeek {
            case .sunday:
                dayLabel.textColor = .sundayText
            case .saturday:
                dayLabel.textColor = .saturdayText
            default:
                dayLabel.textColor = .gray900
            }
            dayLabel.backgroundColor = .clear
        }
        
        self.isUserInteractionEnabled = dateBelongsToThisMonth
        dayLabel.isHidden = !dateBelongsToThisMonth
        selectedView.isHidden = !isSelected
        
        let displayCount = 4
        switch calendarMode {
        case .personal:
            workContainerVStackView.updatePersonalModeWorkRows(workList: workList, displayCount: displayCount)
        case .shared:
            workContainerVStackView.updateSharedModeWorkRows(workList: workList, displayCount: displayCount)
        }
    }
}

private extension CalendarDayCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        self.contentView.addSubviews(seperatorView,
                                     selectedView,
                                     dayLabel,
                                     workContainerVStackView)
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.contentView.backgroundColor = .primaryBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        seperatorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        selectedView.snp.makeConstraints {
            $0.top.equalTo(seperatorView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        dayLabel.snp.makeConstraints {
            $0.top.equalTo(seperatorView.snp.bottom).offset(4)
            $0.width.height.equalTo(20)
            $0.centerX.equalToSuperview()
        }
        
        workContainerVStackView.snp.makeConstraints {
            $0.top.equalTo(dayLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(2)
        }
    }
}
