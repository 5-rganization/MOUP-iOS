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
    private let dateLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(14)
        $0.textAlignment = .center
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    /// 근무 컨테이너 UI
    private let eventContainerVStackView = EventContainerVStackView()
    
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
        
        // eventContainerVStackView의 minY 계산
        let eventContainerMinY = dateLabel.frame.maxY + 4
        
        // eventContainerVStackView의 너비 계산
        let targetWidth = self.contentView.bounds.width - 4
        // systemLayoutSizeFitting에 전달할 목표 크기 계산 - 너비는 targetWidth, 높이는 시스템이 계산
        let targetSize = CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height)
        // targetSize를 이용하여 eventContainerVStackView의 잠재적인 최대 높이 계산
        let requiredHeight = eventContainerVStackView.systemLayoutSizeFitting(targetSize,
                                                                              withHorizontalFittingPriority: .required,
                                                                              verticalFittingPriority: .fittingSizeLevel).height
        // eventContainerVStackView의 잠재적인 maxY 계산
        let potentialMaxY = eventContainerMinY + requiredHeight
        
        // 근무 컨테이너 UI가 캘린더 셀을 벗어났을 때(혹은 공간이 4 미만일 때)
        if potentialMaxY + 4 >= self.contentView.bounds.height {
            // eventContainerVStackView가 isReduced인 상태가 아니라면
            if !eventContainerVStackView.isReduced {
                // 근무 UI 크기 줄임
                eventContainerVStackView.reduceSize()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // 근무 UI 크기 원상 복구
        eventContainerVStackView.restoreSize()
    }
    
    // MARK: - Internal Methods
    func update(dateStr: String, isToday: Bool, daysOfWeek: DaysOfWeek, dateBelongsToThisMonth: Bool, isSelected: Bool, calendarMode: CalendarMode, eventList: [CalendarEvent]) {
        dateLabel.text = dateStr
        
        if isToday {
            dateLabel.textColor = .white
            dateLabel.backgroundColor = .gray900
        } else {
            switch daysOfWeek {
            case .sunday:
                dateLabel.textColor = .sundayText
            case .saturday:
                dateLabel.textColor = .saturdayText
            default:
                dateLabel.textColor = .gray900
            }
            dateLabel.backgroundColor = .clear
        }
        
        self.isUserInteractionEnabled = dateBelongsToThisMonth
        dateLabel.isHidden = !dateBelongsToThisMonth
        selectedView.isHidden = !isSelected
        
        eventContainerVStackView.update(calendarMode: calendarMode, eventList: eventList)
        if !eventList.isEmpty {
            layoutIfNeeded()
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
                                     dateLabel,
                                     eventContainerVStackView)
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
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(seperatorView.snp.bottom).offset(4)
            $0.width.height.equalTo(20)
            $0.centerX.equalToSuperview()
        }
        
        eventContainerVStackView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(2)
        }
    }
}
