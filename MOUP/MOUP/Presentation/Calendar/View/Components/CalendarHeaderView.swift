//
//  CalendarHeaderView.swift
//  MOUP
//
//  Created by 서동환 on 7/18/25.
//

import UIKit

import BetterSegmentedControl
import RxCocoa
import RxSwift
import SnapKit
import Then

/// 캘린더 헤더 UI
final class CalendarHeaderView: UIView {
    // MARK: - UI Components
    /// 연/월 이동 버튼
    fileprivate let yearMonthButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("2001.01", attributes: .init([.font: UIFont.headBold(20), .foregroundColor: UIColor.gray900]))
        config.titleAlignment = .leading
        config.image = .yearMonthChevronDown.withTintColor(.gray900, renderingMode: .alwaysOriginal)
        config.imagePlacement = .trailing
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        
        $0.configuration = config
    }
    /// 캘린더 개인/공유 모드 전환 토글 세그먼트
    fileprivate let toggleSegment = CalendarModeSegmentedControl(items: CalendarMode.allCases.map { $0.rawValue })
    /// 필터 버튼
    fileprivate let filterButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .filterButton.withTintColor(.gray700, renderingMode: .alwaysOriginal)
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 10, bottom: 12, trailing: 10)
        
        $0.configuration = config
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
    
    // MARK: - Methods
    func update(dateStr: String) {
        yearMonthButton.configuration?.attributedTitle?.characters = .init(dateStr)
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
        self.addSubviews(yearMonthButton, toggleSegment, filterButton)
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        yearMonthButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.height.equalTo(44)
            $0.centerY.equalToSuperview()
        }
        
        toggleSegment.snp.makeConstraints {
            $0.trailing.equalTo(filterButton.snp.leading).offset(-2)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(90)
            $0.height.equalTo(25)
        }
        
        filterButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(6)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }
    }
}

// MARK: - Extension Reactive
extension Reactive where Base: CalendarHeaderView {
    var yearMonthButtonTap: ControlEvent<Void> { base.yearMonthButton.rx.tap }
    var toggleSegmentSelectedIndex: ControlProperty<Int> { base.toggleSegment.rx.selectedSegmentIndex }
    var filterButtonTap: ControlEvent<Void> { base.filterButton.rx.tap }
}

// MARK: - Getter
extension CalendarHeaderView {
    var getYearMonthButtonTitle: String? { yearMonthButton.configuration?.title }
}
