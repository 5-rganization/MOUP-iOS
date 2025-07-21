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

final class CalendarDayCell: JTACDayCell {
    
    // MARK: - Properties
    
    static let identifier = String(describing: CalendarDayCell.self)
    
    // MARK: - UI Components
    
    private let _seperatorView = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    private let _selectedView = UIView().then {
        $0.backgroundColor = .primary50
        $0.isHidden = true
    }
    
    private let _dayLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(14)
        $0.textAlignment = .center
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
    }
    
    // MARK: - Getter
    
    var selectedView: UIView { _selectedView }
    var dayLabel: UILabel { _dayLabel }
    
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
        _dayLabel.backgroundColor = .clear
    }
    
    // MARK: - Methods
    
    func update(dateStr: String, daysOfWeek: DaysOfWeek, isToday: Bool) {
        _dayLabel.text = dateStr
        
        if isToday {
            _dayLabel.textColor = .white
            _dayLabel.backgroundColor = .gray900
        } else {
            switch daysOfWeek {
            case .sunday:
                _dayLabel.textColor = .sundayText
            case .saturday:
                _dayLabel.textColor = .saturdayText
            default:
                _dayLabel.textColor = .gray900
            }
        }
    }
}

// MARK: - UI Methods

private extension CalendarDayCell {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        self.contentView.addSubviews(_seperatorView,
                                     _selectedView,
                                     _dayLabel)
    }
    
    func setStyles() {
        self.contentView.backgroundColor = .primaryBackground
    }
    
    func setConstraints() {
        _seperatorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        _selectedView.snp.makeConstraints {
            $0.top.equalTo(_seperatorView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        _dayLabel.snp.makeConstraints {
            $0.top.equalTo(_seperatorView.snp.bottom).offset(4)
            $0.width.height.equalTo(20)
            $0.centerX.equalToSuperview()
        }
    }
}
