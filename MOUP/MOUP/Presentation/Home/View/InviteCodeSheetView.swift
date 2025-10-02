//
//  InviteCodeSheetView.swift
//  MOUP
//
//  Created by 송규섭 on 9/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class InviteCodeSheetView: UIView {
    // MARK: - Properties
    
    // MARK: - UI Components
    private let pageTitleLabel = UILabel().then {
        $0.font = .headBold(18)
        $0.text = "초대 코드"
        $0.textAlignment = .center
    }
    
    private let bottomDivider = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    private let inviteCodeLabel = UILabel().then {
        $0.font = .headBold(24)
        $0.text = "XC1234"
        $0.textColor = .black
        $0.textAlignment = .center
    }
    
    fileprivate let copyButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        
        config.image = .copyButton
        config.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 14, bottom: 13, trailing: 14)
        config.baseBackgroundColor = .primaryBackground
        $0.configuration = config
    } // TODO: - 클립보드 복사 성공 이후 버튼 image n초 간 전환 필요
    
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
    func applyCopySuccessed() { // VC에서 클립보드 복사 성공 시 복사 버튼에 대한 콜백
        
    }
}

private extension InviteCodeSheetView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            pageTitleLabel,
            bottomDivider,
            inviteCodeLabel,
            copyButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .primaryBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        pageTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview()
            $0.width.equalTo(99)
            $0.height.equalTo(47)
        }
        
        bottomDivider.snp.makeConstraints {
            $0.top.equalTo(pageTitleLabel.snp.bottom)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        
        inviteCodeLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        copyButton.snp.makeConstraints {
            $0.leading.equalTo(inviteCodeLabel.snp.trailing)
            $0.centerY.equalTo(inviteCodeLabel)
            $0.size.equalTo(44)
        }
    }
}

extension Reactive where Base: InviteCodeSheetView {
    var copyBtnTapped: ControlEvent<Void> {
        return base.copyButton.rx.tap
    }
}
