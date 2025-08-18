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
    fileprivate let selectedView = UIView().then {
        $0.backgroundColor = .primary50
        $0.isHidden = true
    }
    /// 날짜(일) 라벨
    fileprivate let dateLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(14)
        $0.textAlignment = .center
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    /// 근무 컨테이너 스택
    private let eventsVStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
    }
    /// 첫 번째 열 근무 표시 UI
    private let firstEventRow = CalendarEventVStackView()
    /// 두 번째 열 근무 표시 UI
    private let secondEventRow = CalendarEventVStackView()
    /// 세 번째 열 근무 표시 UI
    private let thirdEventRow = CalendarEventVStackView()
    /// 근무 개수 표시 UI
    private let eventCountRow = EventCountLabel()
    
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
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.backgroundColor = .clear
    }
    
    // MARK: - Methods
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
        }
        
        self.isUserInteractionEnabled = dateBelongsToThisMonth
        dateLabel.isHidden = !dateBelongsToThisMonth
        selectedView.isHidden = !isSelected
        
        eventsVStackView.subviews.forEach { $0.isHidden = true }
        
        if !eventList.isEmpty {
            if calendarMode == .shared && eventList.count > 3 {
                eventCountRow.text = "+\(eventList.count - 3)"
                eventCountRow.isHidden = false
            }
            
            for (index, event) in eventList.enumerated() {
                if index > 2 {
                    break
                } else {
                    guard let eventRow = eventsVStackView.subviews[index] as? CalendarEventVStackView else { continue }
                    eventRow.update(calendarMode: calendarMode, event: event)
                    eventRow.isHidden = false
                }
            }
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
                                     eventsVStackView)
        
        eventsVStackView.addArrangedSubviews(firstEventRow,
                                             secondEventRow,
                                             thirdEventRow,
                                             eventCountRow)
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
        
        eventsVStackView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview().inset(2)
        }
        
        eventCountRow.snp.makeConstraints {
            $0.height.equalTo(17)
        }
    }
}
