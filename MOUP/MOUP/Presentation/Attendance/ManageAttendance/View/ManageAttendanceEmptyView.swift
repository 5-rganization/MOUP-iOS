//
//  ManageAttendanceEmptyView.swift
//  MOUP
//
//  Created by 송규섭 on 9/26/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class ManageAttendanceEmptyView: UIView {
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = .headBold(22)
        $0.textColor = .gray900
        $0.text = "아직 등록된 알바생이 없어요"
        $0.textAlignment = .center
    }
    
    private let commentLabel = UILabel().then {
        $0.font = .bodyMedium(14)
        $0.textColor = .gray700
        $0.text = "알바생 등록이 완료되면\n출퇴근 기록과 근무 일정 관리를 간편하게 할 수 있어요!\n초대 코드를 전송해 바로 시작해보세요!"
        $0.setLineSpacing(.bodyMedium)
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    fileprivate let inviteButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        var titleAttributes = AttributeContainer()
        titleAttributes.font = UIFont.buttonSemibold(16)
        
        config.attributedTitle = AttributedString("알바생 초대하기", attributes: titleAttributes)
        config.baseBackgroundColor = .primary50
        config.baseForegroundColor = .primary600
        config.background.cornerRadius = 12
        
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
    
    // MARK: - Public Methods
}

private extension ManageAttendanceEmptyView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            titleLabel,
            commentLabel,
            inviteButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .primaryBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(159)
            $0.centerX.equalToSuperview()
        }
        
        commentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        inviteButton.snp.makeConstraints {
            $0.top.equalTo(commentLabel.snp.bottom).offset(83)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(307)
            $0.height.equalTo(44)
        }
    }
}

extension Reactive where Base: ManageAttendanceEmptyView {
    var inviteBtnTapped: ControlEvent<Void> {
        return base.inviteButton.rx.tap
    }
}
