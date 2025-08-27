//
//  BaseEventCell.swift
//  MOUP
//
//  Created by 서동환 on 8/27/25.
//

import UIKit

import SnapKit
import Then

class BaseEventCell: UITableViewCell {
    
    // MARK: - UI Components
    /// 라벨 컬러 UI
    let labelColorBorderView = LabelColorBorderView(frame: .zero)
    /// 근무지 or 근무자 이름 라벨
    let titleLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    /// 연동 표시 칩 UI
    let sharedChipLabel = ChipView(title: "연동")
    /// 좌측 상단 수평 컨테이너
    let topLeadingHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    /// 근무 시간 라벨
    let workHourLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    /// 좌측 수직 컨테이너
    let leadingVStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .leading
        $0.distribution = .fillEqually
    }
    /// 수정/삭제 메뉴 표시용 버튼
    let ellipsisButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .ellipsisButton.withTintColor(.gray700, renderingMode: .alwaysOriginal)
        
        $0.configuration = config
    }
    /// 일급 라벨
    let dailyIncomeLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
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
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16))
        
        self.backgroundView = labelColorBorderView
        self.backgroundView?.frame = self.contentView.frame
    }
    
    // MARK: - Internal Methods
    func update(event: CalendarEvent) {
        fatalError("update() 메서드 실행 실패 - 메서드가 오버라이딩 되지 않았습니다.")
    }
}

// MARK: - UI Methods
private extension BaseEventCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        self.contentView.addSubviews(leadingVStackView, ellipsisButton,
                                     dailyIncomeLabel)
        
        topLeadingHStackView.addArrangedSubviews(titleLabel, sharedChipLabel)
        
        leadingVStackView.addArrangedSubviews(topLeadingHStackView,
                                                    workHourLabel)
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.selectionStyle = .none
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        leadingVStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().inset(16)
        }
        
        sharedChipLabel.snp.makeConstraints {
            $0.width.equalTo(37)
            $0.height.equalTo(18)
        }
        
        ellipsisButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(6)
            $0.width.equalTo(44)
            $0.height.equalTo(30)
        }
        
        dailyIncomeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(8)
            $0.height.equalTo(24)
        }
    }
}
