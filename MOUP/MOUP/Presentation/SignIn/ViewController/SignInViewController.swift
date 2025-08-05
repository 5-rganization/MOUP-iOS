//
//  SignInViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit
import RxSwift
import GoogleSignIn

protocol SignInViewControllerDelegate: AnyObject {
    func moveToRegistration()
    func moveToTabBar()
}

final class SignInViewController: UIViewController {
    
    // MARK: - Properties
    private let signInVM: SignInViewModel
    private let signInView = SignInView()
    private let disposeBag = DisposeBag()
    weak var delegate: SignInViewControllerDelegate?

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
    init(signInViewModel: SignInViewModel) {
        self.signInVM = signInViewModel
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
    func setActions() { }
    func setBinding() {
        signInView.rx.googleLoginTap.subscribe(onNext: { [weak self] _ in
            guard let self else { return }
            print("VC - 구글 로그인 시도됨")
            self.signInGoogle()
        })
        .disposed(by: disposeBag)
    }

    // MARK: - signInGoogle
    func signInGoogle() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self else { return }

            if let error {
                print(error.localizedDescription)
                return
            }

            guard let user = result?.user,
                  let userIdentifier = user.userID,
                  let identityToken = user.idToken?.tokenString else {
                return
            }

            signInVM.googleLoginTriggered.accept(SignInRequestDTO(provider: "LOGIN_GOOGLE", idToken: identityToken))
            print("user: \(user)\nidToken: \(identityToken)")
        }
    }
}
