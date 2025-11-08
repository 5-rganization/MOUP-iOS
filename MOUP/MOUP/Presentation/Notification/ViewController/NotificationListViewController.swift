//
//  NotificationListViewController.swift
//  MOUP
//
//  Created by 신영 on 11/2/25.
//

import UIKit
import RxSwift

final class NotificationListViewController: UIViewController {
    
    // MARK; - Properties
    
    private let notificationListView = NotificationListView()
    private let viewModel: NotificationListViewModel
    private let disposeBag = DisposeBag()
    
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let refreshSubject = PublishSubject<Void>()
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = notificationListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        viewDidLoadSubject.onNext(())
        observerPushNotifications()
    }
    
    // MARK: - Initializer
    
    init(viewModel: NotificationListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private extension NotificationListViewController {
    // MARK: - configure
    func configure() {
        setBindings()
    }
    
    // MARK: - setBindings
    func setBindings() {
        notificationListView.rx.backButtonTapped
            .bind(with: self) { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        let deleteAllConfirmed = notificationListView.rx.deleteAllTapped
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                
                return Observable.create { observer in
                    let alert = DeleteAlertViewController(
                        alertTitle: "모든 알림 삭제",
                        alertMessage: "모든 알림을 삭제하시겠습니까?"
                    )
                    
                    alert.onDeleteConfirmed = {
                        observer.onNext(())
                        observer.onCompleted()
                    }
                    
                    self.present(alert, animated: false)
                    
                    return Disposables.create()
                }
            }
        
        let input = NotificationListViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            notificationTapped: notificationListView.rx.notificationTapped.asObservable(),
            markAllReadTapped: notificationListView.rx.markAllReadTapped.asObservable(),
            deleteAllTapped: deleteAllConfirmed,
            refreshTrigger: refreshSubject.asObservable()
        )
        
        let output = viewModel.transform(input)
        
        output.isLoading
            .drive(with: self) { owner, isLoading in
                if isLoading {
                    owner.notificationListView.showLoading()
                } else {
                    owner.notificationListView.hideLoading()
                }
            }
            .disposed(by: disposeBag)
        
        output.notifications
            .drive(with: self) { owner, notifications in
                owner.notificationListView.updateNotifications(notifications)
            }
            .disposed(by: disposeBag)
        
        output.error
            .emit(with: self) { owner, message in
                print("에러: \(message)")
                // TODO: - 에러 알림 표시
            }
            .disposed(by: disposeBag)
        
        output.unreadCount
            .drive(with: self) { owner, count in
                print("읽지 않은 알림: \(count)개")
                // TODO: - 배지 업데이트
            }
            .disposed(by: disposeBag)
    }
    
    func observerPushNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePushNotificationReceived),
            name: .pushNotificationReceived,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePushNotificationReceived),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc func handlePushNotificationReceived() {
        refreshSubject.onNext(())
    }
}
