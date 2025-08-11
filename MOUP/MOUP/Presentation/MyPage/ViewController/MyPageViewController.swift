//
//  MyPageViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit
import RxSwift
import MessageUI

final class MyPageViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var coordinator: MyPageCoordinator?
    
    private let mypageView = MyPageView()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = mypageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
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
            .subscribe(onNext: {
                print("editButton tapped")
            })
            .disposed(by: disposeBag)
        
        mypageView.rx.logoutButtonTapped
            .subscribe(onNext: {
                print("logoutButton tapped")
            })
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
