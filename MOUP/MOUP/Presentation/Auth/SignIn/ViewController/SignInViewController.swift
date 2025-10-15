//
//  SignInViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit
import RxSwift
import RxRelay
import GoogleSignIn

final class SignInViewController: UIViewController {
    
    // MARK: - Properties
    private let signInVM: SignInViewModel
    private let signInView = SignInView()
    private let disposeBag = DisposeBag()
    weak var coordinator: SignInCoordinator?

    private let googleAuthCodeRelay = BehaviorRelay<String>(value: "")

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
        let input = SignInViewModel.Input(
            googleLoginTap: signInView.rx.googleLoginTap.asObservable(),
            googleAuthCode: googleAuthCodeRelay.asObservable()
        )

        let output = signInVM.transform(input: input)

        output.startGoogleLogin
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.signInGoogle()
            }
            .disposed(by: disposeBag)

        Observable.combineLatest(output.signInResult, output.loginProvider)
            .withUnretained(self)
            .observe(on: MainScheduler.instance )
            .subscribe(
                onNext: {
                    owner,
                    tuple in
                    switch tuple.0 {
                    case .loginSuccessed:
                        print("로그인 성공")
                        owner.coordinator?.moveToTabBar()
                    case .navigateToSignUp:
                        print("회원가입 필요")
                        guard let provider = tuple.1 else {
                            print("provider is nil")
                            return
                        }
                        owner.coordinator?.moveToSignUp(
                            provider: provider,
                            authorizationCode: owner.googleAuthCodeRelay.value
                        )
                    case .showAlert(let error):
                        print("로그인 실패 : \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)


    }

    // MARK: - signInGoogle
//    func signInGoogle() {
//        let config = OIDServiceConfiguration(
//            authorizationEndpoint: URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!,
//            tokenEndpoint: URL(string: "https://oauth2.googleapis.com/token")!
//        )
//
//        guard let redirectURI = Bundle.main.googleRedirectURI else {
//            print("googleRedirectURI를 찾을 수 없음")
//            return
//        }
//
//        print("googleClientID: \(Bundle.main.googleClientID)\nredirectURI: \(redirectURI)")
//
//        let request = OIDAuthorizationRequest(
//            configuration: config,
//            clientId: Bundle.main.googleClientID,
//            scopes: ["openid", "profile", "email"],
//            redirectURL: URL(string: redirectURI)!,
//            responseType: OIDResponseTypeCode,
//            additionalParameters: nil
//        )
//
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            appDelegate.currentAuthorizationFlow = OIDAuthorizationService.present(
//                request,
//                presenting: self,
//                callback: { response, error in
//                    if let code = response?.authorizationCode,
//                       let codeVerifier = request.codeVerifier {
//                        print("request... => \(codeVerifier) \(code)")
//                        self.googleAuthCodeRelay.accept("\(codeVerifier) \(code)")
//                    } else {
//                        print("Authorization failed: \(error?.localizedDescription ?? "")")
//                    }
//                }
//            )
//        }
//    }

    func signInGoogle() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { result, error in
            guard error == nil else {
                // TODO: - 에러 핸들링 필요
                return
            }

            if let serverAuthCode = result?.serverAuthCode {
                self.googleAuthCodeRelay.accept(serverAuthCode)
            } else {
                assertionFailure("Authorization failed - serverAuthCode")
            }
        }
    }
}
