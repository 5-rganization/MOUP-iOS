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
    private let googleLoginTappedRelay = PublishRelay<Void>()

    // MARK: - UI Components
    private let logo = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = .logo
    }
    
    private(set) var appleLoginButton = UIButton().then {
        $0.setImage(.appleSignInButton, for: .normal)
    }
    
    private(set) var googleLoginButton = UIButton().then {
        $0.setImage(.googleSignInButton, for: .normal)
    }

    // MARK: - Getter
    var googleLoginTap: Observable<Void> {
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
            appleLoginButton,
            googleLoginButton
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        logo.snp.makeConstraints {
            $0.top.equalToSuperview().offset(208)
            $0.horizontalEdges.equalToSuperview().inset(71.5)
        }
        appleLoginButton.snp.makeConstraints {
            $0.top.equalTo(logo.snp.bottom).offset(100)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        googleLoginButton.snp.makeConstraints {
            $0.top.equalTo(appleLoginButton.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }

    func setActions() {
        googleLoginButton.addTarget(self, action: #selector(didTapGoogleLogin), for: .touchUpInside)
    }

    @objc private func didTapGoogleLogin() {
        googleLoginTappedRelay.accept(())
    }
}

extension Reactive where Base: SignInView {
    // TODO: - 로그인 버튼 tapEvent 구현 및 VC 측 관련 로직 수행
    var googleLoginTap: ControlEvent<Void> {
        return ControlEvent(events: base.googleLoginTap)
    }
}
