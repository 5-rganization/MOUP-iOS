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

final class CalendarHeaderView: UIView {
    
    // MARK: - UI Components
    
    /// 연.월 표시 및 `UIPickerView` 사용을 위한 `UIButton`
    private let yearMonthButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.attributedTitle = AttributedString("2001.01", attributes: .init([.font: UIFont.headBold(20), .foregroundColor: UIColor.gray900]))
        config.titleAlignment = .leading
        config.image = UIImage()
        config.imagePlacement = .trailing
        config.imagePadding = 8 + UIImage.yearMonthChevron.size.width
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 8)
        
        $0.configuration = config
    }
    
    private let chevronImageView = UIImageView().then {
        $0.image = .yearMonthChevron.withTintColor(.gray900, renderingMode: .alwaysOriginal)
        
    }
    
    /// 토글 스위치 `BetterSegmentedControl` 라이브러리
    private let toggleSwitch = BetterSegmentedControl().then {
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
    
    /// 필터 `UIButton`
    private let filterButton = UIButton().then {
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
}

private extension CalendarHeaderView {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    func setHierarchy() {
        self.addSubviews(yearMonthButton, toggleSwitch, filterButton)
        
        yearMonthButton.addSubview(chevronImageView)
    }
    
    func setStyles() {
        
    }
    
    func setConstraints() {
        yearMonthButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.height.equalTo(44)
            $0.centerY.equalToSuperview()
        }
        
        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
        
        toggleSwitch.snp.makeConstraints {
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
