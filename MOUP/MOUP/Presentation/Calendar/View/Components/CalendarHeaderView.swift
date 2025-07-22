//
//  CalendarHeaderView.swift
//  MOUP
//
//  Created by 서동환 on 7/18/25.
//

import UIKit

import BetterSegmentedControl
import SnapKit
import Then

/// 캘린더 헤더 UI
final class CalendarHeaderView: UIView {
    // MARK: - UI Components
    /// 연/월 이동 버튼
    private let _yearMonthButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("2001.01", attributes: .init([.font: UIFont.headBold(20), .foregroundColor: UIColor.gray900]))
        config.titleAlignment = .leading
        config.image = .yearMonthChevronDown.withTintColor(.gray900, renderingMode: .alwaysOriginal)
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        $0.configuration = config
    }
    /// 개인 ↔️ 공유 토글 버튼
    private let _toggleSwitch = BetterSegmentedControl().then {
        $0.segments = LabelSegment.segments(withTitles: ["개인", "공유"],
                                            normalFont: .buttonSemibold(16),
                                            normalTextColor: .gray400,
                                            selectedFont: .buttonSemibold(16),
                                            selectedTextColor: .white)
        $0.setOptions([.cornerRadius(12.5),
                       .indicatorViewBackgroundColor(.gray700),
                       .backgroundColor(.gray100)])
        $0.indicatorViewInset = 1
        
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.layer.borderWidth = 1
    }
    /// 필터 버튼
    private let _filterButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .filterButton.withTintColor(.gray700, renderingMode: .alwaysOriginal)
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10)
        
        $0.configuration = config
    }
    
    // MARK: - Getter
    var yearMonthButton: UIButton { _yearMonthButton }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Methods
    func update(date: Date) {
        let dateStr = DateFormatter.yearMonthDateFormatter.string(from: date)
        _yearMonthButton.configuration?.attributedTitle?.characters = .init(dateStr)
    }
}

private extension CalendarHeaderView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {
        self.addSubviews(_yearMonthButton, _toggleSwitch, _filterButton)
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        _yearMonthButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.height.equalTo(44)
            $0.centerY.equalToSuperview()
        }
        
        _toggleSwitch.snp.makeConstraints {
            $0.trailing.equalTo(_filterButton.snp.leading).offset(-2)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(90)
            $0.height.equalTo(25)
        }
        
        _filterButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(6)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }
    }
}
