//
//  CalendarDayCell.swift
//  MOUP
//
//  Created by 서동환 on 7/21/25.
//

import UIKit

import JTAppleCalendar
import RxCocoa
import RxSwift
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
    func update(dateStr: String, daysOfWeek: DaysOfWeek, dateBelongsToThisMonth: Bool, isSelected: Bool, isToday: Bool) {
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
        
        dateLabel.isHidden = !dateBelongsToThisMonth
        self.isUserInteractionEnabled = dateBelongsToThisMonth
        
        selectedView.isHidden = !isSelected
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
                                     dateLabel)
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
    }
}
