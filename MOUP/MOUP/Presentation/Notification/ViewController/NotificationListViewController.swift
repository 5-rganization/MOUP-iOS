//
//  NotificationListViewController.swift
//  MOUP
//
//  Created by 신영 on 11/2/25.
//

import UIKit
import RxSwift

final class NotificationListViewController: UIViewController {
    
    // MARK: - Properties
    
    private let notificationListView = NotificationListView()
    private let viewModel: NotificationListViewModel
    private let disposeBag = DisposeBag()
    
    private let viewDidLoadSubject = PublishSubject<Void>()
    private let refreshSubject = PublishSubject<Void>()

    private var pushNotificationMetadata: (type: String?, workerId: Int?, workplaceId: Int?)?
    private var pendingPushData: (id: Int?, metadata: NotificationMetadata?)?
    
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

    init(
        viewModel: NotificationListViewModel,
        pushType: String? = nil,
        pushWorkerId: Int? = nil,
        pushWorkplaceId: Int? = nil,
        pushNotificationId: Int? = nil
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        let pushNotificationType = PushNotificationType(from: pushType)
        if pushNotificationType != nil || pushWorkerId != nil || pushWorkplaceId != nil {
            let metadata = NotificationMetadata(
                type: pushNotificationType,
                workerId: pushWorkerId,
                workplaceId: pushWorkplaceId
            )
            pendingPushData = (id: pushNotificationId, metadata: metadata)
        }
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
            refreshTrigger: refreshSubject.asObservable(),
            deleteTapped: notificationListView.rx.deleteTapped.asObservable(),
            approveTapped: notificationListView.rx.approveTapped.asObservable(),
            rejectTapped: notificationListView.rx.rejectTapped.asObservable()
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
                let readCount = notifications.filter { $0.isRead }.count
                let updatedNotifications = owner.applyPushMetadata(to: notifications)
                let updatedReadCount = updatedNotifications.filter { $0.isRead }.count

                owner.notificationListView.updateNotifications(updatedNotifications)
            }
            .disposed(by: disposeBag)
        
        output.error
            .emit(with: self) { owner, message in
                // TODO: - 에러 알림 표시
            }
            .disposed(by: disposeBag)
        
        output.unreadCount
            .drive(with: self) { owner, count in
                // TODO: - 배지 업데이트
            }
            .disposed(by: disposeBag)
        
        output.approveSuccess
            .emit(with: self) { owner, _ in
                // TODO: - 성공 메시지 표시
            }
            .disposed(by: disposeBag)
        
        output.rejectSuccess
            .emit(with: self) { owner, _ in
                // TODO: - 성공 메시지 표시
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePushNotificationTapped),
            name: .pushNotificationTapped,
            object: nil
        )
    }

    @objc func handlePushNotificationReceived() {
        refreshSubject.onNext(())
    }

    @objc func handlePushNotificationTapped(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let notificationId = userInfo[PushNotificationKey.notificationId] as? Int
        else { return }

        let typeString = userInfo[PushNotificationKey.type] as? String
        let pushNotificationType = PushNotificationType(from: typeString)
        let workerId = userInfo[PushNotificationKey.workerId] as? Int
        let workplaceId = userInfo[PushNotificationKey.workplaceId] as? Int

        let metadata = (pushNotificationType != nil || workerId != nil || workplaceId != nil)
            ? NotificationMetadata(type: pushNotificationType, workerId: workerId, workplaceId: workplaceId)
            : nil
        
        pendingPushData = (id: notificationId, metadata: metadata)
        refreshSubject.onNext(())
    }

    private func applyPushMetadata(to notifications: [UserNotification]) -> [UserNotification] {
        guard let pending = pendingPushData else { return notifications }

        guard !notifications.isEmpty else {
            return notifications
        }

        defer {
            pendingPushData = nil
        }

        return notifications.map { notification in
            let shouldApplyMetadata: Bool
            if let pendingId = pending.id {
                shouldApplyMetadata = notification.id == pendingId
            } else if let pushMeta = pending.metadata {
                let typeMatch = pushMeta.type != nil && notification.title.contains("참가 요청")
                let workerIdMatch = pushMeta.workerId != nil
                let workplaceIdMatch = pushMeta.workplaceId != nil

                shouldApplyMetadata = typeMatch && workerIdMatch && workplaceIdMatch
            } else {
                shouldApplyMetadata = false
            }

            guard shouldApplyMetadata else { return notification }

            let finalMetadata: NotificationMetadata?
            if let pushMeta = pending.metadata {
                let mergedType = pushMeta.type ?? notification.type
                let mergedWorkerId = pushMeta.workerId ?? notification.metadata?.workerId
                let mergedWorkplaceId = pushMeta.workplaceId ?? notification.metadata?.workplaceId

                finalMetadata = NotificationMetadata(
                    type: mergedType,
                    workerId: mergedWorkerId,
                    workplaceId: mergedWorkplaceId
                )
            } else {
                finalMetadata = notification.metadata
            }

            let finalType = pending.metadata?.type ?? notification.type

            return UserNotification(
                id: notification.id,
                senderId: notification.senderId,
                receiverId: notification.receiverId,
                title: notification.title,
                content: notification.content,
                sentAt: notification.sentAt,
                readAt: notification.readAt,
                type: finalType,
                metadata: finalMetadata
            )
        }
    }
}
