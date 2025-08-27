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
    private let labelColorBorderView = LabelColorBorderView()
    /// 근무지 or 근무자 이름 라벨
    let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }
    /// 연동 표시 칩 UI
    let sharedChipLabel = ChipView(title: "연동")
    /// 좌측 상단 수평 컨테이너
    private let topLeadingHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    /// 출근 시간 ~ 퇴근 시간 라벨
    private let startEndTimeLabel = UILabel().then {
        $0.font = .bodyMedium(14)
        $0.textColor = .gray900
    }
    /// 근무 시간 라벨
    private let workHourLabel = UILabel().then {
        $0.font = .bodyMedium(12)
        $0.textColor = .gray900
    }
    /// 좌측 하단 수평 컨테이너
    private let bottomLeadingHStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    /// 좌측 수직 컨테이너
    private let leadingVStackView = UIStackView().then {
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
        $0.font = .bodyMedium(14)
        $0.textColor = .gray900
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
    
    // MARK: - Override Methods
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
        bottomLeadingHStackView.addArrangedSubviews(startEndTimeLabel, workHourLabel)
        
        leadingVStackView.addArrangedSubviews(topLeadingHStackView,
                                              bottomLeadingHStackView)
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

// MARK: - Internal Methods
extension BaseEventCell {
    /// 설정된 라벨 컬러를 적용하는 메서드
    func setGivenLabelColor(_ labelColorStr: String) {
        guard let labelColor = LabelColorString(rawValue: labelColorStr) else {
            assertionFailure("setGivenLabelColor() 메서드 실행 실패 - labelColorStr 값이 올바르지 않습니다.")
            return
        }
        labelColorBorderView.update(borderColor: labelColor)
    }
    
    /// 기본 라벨 컬러를 적용하는 메서드
    func setDefaultLabelColor() {
        labelColorBorderView.update(borderColor: ._default)
    }
    
    func setTimeInfoUI(startTime: String, endTime: String, restTime: Int) {
        if let workHour = DateFormatter.calculateWorkHour(startTime: startTime, endTime: endTime, restTime: restTime) {
            startEndTimeLabel.text = "\(startTime) ~ \(endTime)"
            var workHourText: String
            if workHour.minutesInt == 0 {
                workHourText = " (\(workHour.hoursInt)시간"
            } else {
                workHourText = " (\(workHour.hoursInt)시간 \(workHour.minutesInt)분"
            }
            
            if restTime > 0 {
                workHourText += " - 휴게 \(restTime)분"
            }
            workHourText += ")"
            workHourLabel.text = workHourText
        } else {
            assertionFailure("calculateWorkHour() 메서드 실행 실패 - Argument가 올바르지 않습니다.")
        }
    }
}
