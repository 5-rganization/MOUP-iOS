//
//  WorkplaceRegistrationSheetView.swift
//  MOUP
//
//  Created by 송규섭 on 10/17/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class WorkplaceRegisterSheetView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = .headBold(18)
        $0.textColor = .gray900
        $0.text = "새 근무지 등록"
        $0.textAlignment = .center
    }
    
    private let divider = UIView().then {
        $0.backgroundColor = .gray300
    }
    
    fileprivate let inviteCodeInputButton = UIControl().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.backgroundColor = .white
    }
    
    private let inviteIcon = UIImageView().then {
        $0.image = .mail
        $0.tintColor = .gray700
    }
    
    private let inviteCodeMenuLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(14)
        $0.text = "초대 코드 입력하기"
    }
    
    fileprivate let directRegistrationButton = UIControl().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.gray400.cgColor
        $0.backgroundColor = .white
    }
    
    private let directRegisterIcon = UIImageView().then {
        $0.image = .plus
        $0.tintColor = .gray700
    }
    
    private let directRegisterMenuLabel = UILabel().then {
        $0.textColor = .gray900
        $0.font = .bodyMedium(14)
        $0.text = "직접 등록하기"
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

private extension WorkplaceRegisterSheetView {
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
            divider,
            inviteCodeInputButton,
            directRegistrationButton
        )
        
        inviteCodeInputButton.addSubviews(
            inviteIcon,
            inviteCodeMenuLabel
        )
        
        directRegistrationButton.addSubviews(
            directRegisterIcon,
            directRegisterMenuLabel
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        self.backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.equalToSuperview().inset(16)
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        
        inviteCodeInputButton.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(12)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
        
        inviteIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        
        inviteCodeMenuLabel.snp.makeConstraints {
            $0.leading.equalTo(inviteIcon.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
        
        directRegistrationButton.snp.makeConstraints {
            $0.top.equalTo(inviteCodeInputButton.snp.bottom).offset(8)
            $0.directionalHorizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
        
        directRegisterIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        
        directRegisterMenuLabel.snp.makeConstraints {
            $0.leading.equalTo(directRegisterIcon.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
    }
}

extension Reactive where Base: WorkplaceRegisterSheetView {
    var inviteCodeRegisterBtnTapped: ControlEvent<Void> {
        base.inviteCodeInputButton.rx.controlEvent(.touchUpInside)
    }
    
    var directRegisterBtnTapped: ControlEvent<Void> {
        base.directRegistrationButton.rx.controlEvent(.touchUpInside)
    }
}
