//
//  SignInView.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

final class SignInView: UIView {
    // MARK: - Properties
    private let appleLoginTappedRelay = PublishRelay<Void>()
    private let googleLoginTappedRelay = PublishRelay<Void>()

    // MARK: - UI Components
    private let logo = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .signInLogo
    }
    
    private(set) var appleLoginButton = UIButton().then {
        $0.setImage(.appleSignInButton, for: .normal)
    }
    
    private(set) var googleLoginButton = UIButton().then {
        $0.setImage(.googleSignInButton, for: .normal)
    }
    
    private let buttonVStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fillEqually
        $0.spacing = 12
    }

    // MARK: - Getter
    fileprivate var appleLoginTap: Observable<Void> {
        appleLoginTappedRelay.asObservable()
    }
    fileprivate var googleLoginTap: Observable<Void> {
        googleLoginTappedRelay.asObservable()
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

private extension SignInView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            logo,
            buttonVStackView
        )
        
        buttonVStackView.addArrangedSubviews(appleLoginButton,
                                             googleLoginButton)
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .primaryBackground
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        logo.snp.makeConstraints {
            $0.width.equalTo(self.safeAreaLayoutGuide).multipliedBy(0.6)
            $0.centerX.equalTo(self.safeAreaLayoutGuide)
            $0.centerY.equalTo(self.safeAreaLayoutGuide).offset(-100)
        }
        
        buttonVStackView.snp.makeConstraints {
            $0.directionalHorizontalEdges.equalTo(self.safeAreaLayoutGuide).inset(16)
            $0.centerX.equalTo(self.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(100)
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        
        googleLoginButton.snp.makeConstraints {
            $0.height.equalTo(44)
        }
    }

    // MARK: - setActions
    func setActions() {
        appleLoginButton.addTarget(self, action: #selector(didTapAppleLogin), for: .touchUpInside)
        googleLoginButton.addTarget(self, action: #selector(didTapGoogleLogin), for: .touchUpInside)
    }
}

// MARK: - @objc Methods
@objc private extension SignInView {
    func didTapAppleLogin() {
        appleLoginTappedRelay.accept(())
    }
    
    func didTapGoogleLogin() {
        googleLoginTappedRelay.accept(())
    }
}

extension Reactive where Base: SignInView {
    // TODO: - 로그인 버튼 tapEvent 구현 및 VC 측 관련 로직 수행
    var googleLoginTap: ControlEvent<Void> {
        return ControlEvent(events: base.googleLoginTap)
    }
    var appleLoginTap: ControlEvent<Void> {
        return ControlEvent(events: base.appleLoginTap)
    }
}
