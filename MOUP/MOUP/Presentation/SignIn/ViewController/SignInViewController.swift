//
//  SignInViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit

final class SignInViewController: UIViewController {
    
    // MARK: - Properties
    
    private let signInView = SignInView()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = signInView
    }
    
    // VC일 때
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    
    // MARK: - Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "compile error")
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc
    private func didTapAppleLoginButton() {
        // TODO: 추후 버튼 액션 연결
        print("Apple 로그인 버튼 클릭됨")
    }

    @objc
    private func didTapGoogleLoginButton() {
        // TODO: 추후 버튼 액션 연결
        print("Google 로그인 버튼 클릭됨")
    }
}

// MARK: - UI Methods

private extension SignInViewController {
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
        setActions()
        setBinding()
    }
    
    // MARK: - setBinding
    func setHierarchy() { }
    func setStyles() { }
    func setConstraints() { }
    func setActions() {
        signInView.appleLoginButton.addTarget(self, action: #selector(didTapAppleLoginButton), for: .touchUpInside)
        signInView.googleLoginButton.addTarget(self, action: #selector(didTapGoogleLoginButton), for: .touchUpInside)
    }
    func setBinding() { }
    
}
