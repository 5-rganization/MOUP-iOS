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
    
    private let viewDidLoadSubject = PublishSubject<Void>()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = mypageView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        viewDidLoadSubject.onNext(())
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
                case .notice:
                    owner.coordinator?.showNoticeList()
                case .contact:
                    owner.presentContactMailComposer()
                case .info:
                    owner.coordinator?.showInfoViewController()
                }
            })
            .disposed(by: disposeBag)
        
        let logoutConfirmed: Observable<Void> = mypageView.rx.logoutButtonTapped
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                return self.presentLogoutConfirmedAsObservable()
            }
            .share()
        
        mypageView.rx.dummyButtonTapped
            .subscribe(onNext: { [weak self] _ in
                let service = NotificationService()
                let repository = NotificationRepository(notificationService: service)
                let useCase = NotificationUseCase(notificationRepository: repository)
                let vm = NotificationListViewModel(notificationUseCase: useCase)
                let vc = NotificationListViewController(viewModel: vm)
                
                self?.navigationController?.pushViewController(vc, animated: false)
            })
            .disposed(by: disposeBag)
        
        mypageView.rx.dummyButton2Tapped
            .subscribe(onNext: { [weak self] _ in
                let coordinator = RoutineSelectionCoordinator(
                    navigationController: self?.navigationController ?? UINavigationController()
                )
                coordinator.start()
            })
            .disposed(by: disposeBag)
        
        let input = MyPageViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            logoutConfirmed: logoutConfirmed
        )
        let output = viewModel.transform(input)
        
        output.isLoading
            .drive(with: self) { owner, isLoading in
                if isLoading {
                    owner.mypageView.showLoading()
                } else {
                    owner.mypageView.hideLoading()
                }
            }
            .disposed(by: disposeBag)
        
        output.profile
            .compactMap { $0 }
            .drive(with: self) { owner, profile in
                owner.mypageView.updateProfile(profile)
            }
            .disposed(by: disposeBag)
        
        output.logoutSuccess
            .emit(with: self) { owner, _ in
                print("로그아웃 성공")
                
                NotificationCenter.default.post(
                    name: .logoutSuccess,
                    object: nil
                )
            }
            .disposed(by: disposeBag)
        
        output.error
            .emit(with: self) { owner, message in
                if message.contains("로그아웃") {
                    owner.coordinator?.showLogoutFail(from: owner) {
                        owner.dismiss(animated: false)
                    }
                } else {
                    print("에러: \(message)")
                }
                
            }
            .disposed(by: disposeBag)
    }
    
    func presentLogoutConfirmedAsObservable() -> Observable<Void> {
        Observable<Void>.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }
            self.coordinator?.showLogoutConfirm(from: self) {
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
        .take(1)
        .observe(on: MainScheduler.instance)
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
