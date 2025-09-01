//
//  MyPageViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit
import RxSwift
import RxCocoa
import MessageUI

final class MyPageViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: MyPageCoordinator?
    private let mypageView = MyPageView()
    private let viewModel: MyPageViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = mypageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    // MARK: - Initializer
    
    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func updateNickname(_ nickname: String) {
        mypageView.updateNickname(nickname)
    }
}

private extension MyPageViewController {
    // MARK: - configure
    func configure() {
        setStyles()
        setBindings()
    }
    
    // MARK: - setStyles
    func setStyles() {
        navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - setBindings
    func setBindings() {
        mypageView.rx.editButtonTapped
            .bind(with: self) { owner, _ in
                owner.coordinator?.showEditNicknameModal()
            }
            .disposed(by: disposeBag)
        
        mypageView.rx.menuTapped
            .withUnretained(self)
            .subscribe(onNext: { owner, menu in
                switch menu {
                case .account:
                    owner.coordinator?.showAccountViewController()
                case .contact:
                    owner.presentContactMailComposer()
                case .info:
                    owner.coordinator?.showInfoViewController()
                }
            })
            .disposed(by: disposeBag)
        
        mypageView.rx.logoutButtonTapped
            .bind(with: self) { owner, _ in
                owner.coordinator?.showLogoutConfirm(from: owner) {
                    owner.viewModel.logoutConfirmed.onNext(())
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .skip(1)
            .drive(with: self) { owner, isLoading in
                if isLoading {
                    print("로그아웃 중입니다.")
                } else {
                    print("로그아웃 종료")
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.logoutSuccess
            .emit(with: self) { owner, _ in
                print("로그아웃 성공! 로그인 화면으로 이동합니다.")
            }
            .disposed(by: disposeBag)
        
        viewModel.error
            .emit(with: self) { owner, message in
                owner.coordinator?.showLogoutFail(from: owner) {
                    owner.dismiss(animated: true)
                    print(message)
                }
            }
            .disposed(by: disposeBag)
    }
}

private extension MyPageViewController {
    func presentContactMailComposer() {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(
                title: "메일 앱을 사용할 수 없습니다",
                message: "기기의 메일 설정을 확인해주세요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = self
        mailComposer.setToRecipients(["ksyq12@daum.net"])
        mailComposer.setSubject("MOUP 문의하기")
        mailComposer.setMessageBody(
            """
            
            문의 내용:
            
            --------------------------
            UID: \("uid")
            iOS Version: \(UIDevice.current.systemVersion)
            App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
            --------------------------
            """,
            isHTML: false
        )
        
        present(mailComposer, animated: true)
    }
}

extension MyPageViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}
