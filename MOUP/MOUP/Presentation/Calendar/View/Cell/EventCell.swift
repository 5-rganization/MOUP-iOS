//
//  EventCell.swift
//  MOUP
//
//  Created by 서동환 on 8/26/25.
//

import UIKit

import SnapKit
import Then

/// 근무 목록 셀
final class EventCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = String(describing: EventCell.self)
    
    // MARK: - UI Components
    private let labelColorBorderView = LabelColorBorderView()
    
    private let workplaceOrWorkerNameLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    /// 연동 표시 칩 UI
    private let sharedChipLabel = ChipView(title: "연동")
    
    private let workplaceChipHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    
    private let workHourLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(16)
    }
    
    private let leadingVStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .leading
        $0.distribution = .fillEqually
    }
    
    private let ellipsisButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = .ellipsisButton.withTintColor(.gray700, renderingMode: .alwaysOriginal)
        
        $0.configuration = config
    }
    
    private let dailyIncomeLabel = UILabel().then {
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
    func update(calendarMode: CalendarMode, event: CalendarEvent) {
        guard let borderColor = LabelColorString(rawValue: event.labelColor) else {
            assertionFailure("LabelColorString 변환 실패 - labelColor 값이 올바르지 않습니다.")
            return
        }
        labelColorBorderView.update(borderColor: borderColor)
    }
}

// MARK: - UI Methods
private extension EventCell {
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
        
        workplaceChipHStackView.addArrangedSubviews(workplaceOrWorkerNameLabel, sharedChipLabel)
        
        leadingVStackView.addArrangedSubviews(workplaceChipHStackView,
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
