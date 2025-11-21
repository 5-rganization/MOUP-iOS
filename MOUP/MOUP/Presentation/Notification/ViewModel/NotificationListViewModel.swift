//
//  NotificationListViewModel.swift
//  MOUP
//
//  Created by 신영 on 11/2/25.
//

import Foundation
import RxSwift
import RxCocoa

final class NotificationListViewModel {
    
    // MARK: - Input
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let notificationTapped: Observable<UserNotification>
        let markAllReadTapped: Observable<Void>
        let deleteAllTapped: Observable<Void>
        let refreshTrigger: Observable<Void>
        let deleteTapped: Observable<UserNotification>
        let approveTapped: Observable<(
            notificationId: Int, workplaceId: Int, workerId: Int
        )>
        let rejectTapped: Observable<(
            notificationId: Int, workplaceId: Int, workerId: Int
        )>
    }
    
    // MARK: - Output
    
    struct Output {
        let notifications: Driver<[UserNotification]>
        let isLoading: Driver<Bool>
        let error: Signal<String>
        let unreadCount: Driver<Int>
        let approveSuccess: Signal<Void>
        let rejectSuccess: Signal<Void>
    }
    
    // MARK: - Properties
    
    private let notificationUseCase: NotificationUseCaseProtocol
    private let workplaceUseCase: WorkplaceUseCaseProtocol
    private let disposeBag = DisposeBag()
    private var approvedNotificationIds: Set<Int> = []
    private var rejectedNotificationIds: Set<Int> = []
    
    // MARK: - Initializer
    
    init(
        notificationUseCase: NotificationUseCaseProtocol,
        workplaceUseCase: WorkplaceUseCaseProtocol
    ) {
        self.notificationUseCase = notificationUseCase
        self.workplaceUseCase = workplaceUseCase
    }

    // MARK: - Helper Methods

    private func applyLocalState(to notifications: [UserNotification]) -> [UserNotification] {
        return notifications.map { notification in
            if approvedNotificationIds.contains(notification.id) {
                return UserNotification(
                    id: notification.id,
                    senderId: notification.senderId,
                    receiverId: notification.receiverId,
                    title: notification.title,
                    content: notification.content,
                    sentAt: notification.sentAt,
                    readAt: notification.readAt,
                    type: .inviteApproved,
                    metadata: notification.metadata
                )
            } else if rejectedNotificationIds.contains(notification.id) {
                return UserNotification(
                    id: notification.id,
                    senderId: notification.senderId,
                    receiverId: notification.receiverId,
                    title: notification.title,
                    content: notification.content,
                    sentAt: notification.sentAt,
                    readAt: notification.readAt,
                    type: .inviteRejected,
                    metadata: notification.metadata
                )
            }
            return notification
        }
    }
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let notificationsRelay = BehaviorRelay<[UserNotification]>(value: [])
        let errorRelay = PublishRelay<String>()
        let approveSuccessRelay = PublishRelay<Void>()
        let rejectSuccessRelay = PublishRelay<Void>()
        let fetchTrigger = Observable.merge(
            input.viewDidLoad,
            input.refreshTrigger
        )
        
        fetchTrigger
            .do(onNext: { _ in
                loadingRelay.accept(true)
            })
            .flatMapLatest { [weak self] _ -> Observable<[UserNotification]> in
                guard let self else { return .just([]) }
                
                return Observable.create { observer in
                    Task {
                        do {
                            let fetchedNotifications = try await self.notificationUseCase.fetchNotifications()

                            let sortedNotification = fetchedNotifications.sorted { $0.sentAt > $1.sentAt }
                            _ = sortedNotification.filter { $0.isRead }.count

                            observer.onNext(sortedNotification)
                            observer.onCompleted()
                        } catch {
                            errorRelay.accept("알림을 불러오는데 실패했습니다.")
                            observer.onNext([])
                            observer.onCompleted()
                        }
                        loadingRelay.accept(false)
                    }
                    return Disposables.create()
                }
            }
            .map { [weak self] notifications -> [UserNotification] in
                guard let self else { return notifications }
                return self.applyLocalState(to: notifications)
            }
            .bind(to: notificationsRelay)
            .disposed(by: disposeBag)
        
        input.notificationTapped
            .filter { !$0.isRead }
            .flatMapLatest { [weak self] tappedNotification -> Observable<Int> in
                guard let self else { return .empty() }
                
                return Observable.create { observer in
                    Task {
                        do {
                            try await self.notificationUseCase.markAsRead(
                                id: tappedNotification.id
                            )
                            observer.onNext(tappedNotification.id)
                            observer.onCompleted()
                        } catch {
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            .withLatestFrom(notificationsRelay) { tappedNotificationId, notifications -> [UserNotification] in

                let updatedNotifications = notifications.map { notification in
                    if notification.id == tappedNotificationId {
                        return UserNotification(
                            id: notification.id,
                            senderId: notification.senderId,
                            receiverId: notification.receiverId,
                            title: notification.title,
                            content: notification.content,
                            sentAt: notification.sentAt,
                            readAt: Date(),
                            type: notification.type,
                            metadata: notification.metadata
                        )
                    }
                    return notification
                }

                _ = updatedNotifications.filter { $0.isRead }.count

                return updatedNotifications
            }
            .bind(to: notificationsRelay)
            .disposed(by: disposeBag)
        
        input.markAllReadTapped
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                
                return Observable.create { observer in
                    Task {
                        do {
                            try await self.notificationUseCase.markAllAsRead()
                            observer.onNext(())
                            observer.onCompleted()
                        } catch {
                            errorRelay.accept("전체 읽음 처리에 실패했습니다.")
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            .withLatestFrom(notificationsRelay) { _, notifications -> [UserNotification] in
                return notifications.map { notification in
                    UserNotification(
                        id: notification.id,
                        senderId: notification.senderId,
                        receiverId: notification.receiverId,
                        title: notification.title,
                        content: notification.content,
                        sentAt: notification.sentAt,
                        readAt: notification.readAt ?? Date(),
                        type: notification.type,
                        metadata: notification.metadata
                    )
                }
            }
            .bind(to: notificationsRelay)
            .disposed(by: disposeBag)
        
        input.deleteAllTapped
            .flatMapLatest { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                
                return Observable.create { observer in
                    Task {
                        do {
                            try await self.notificationUseCase.deleteAllNotifications()
                            observer.onNext(())
                            observer.onCompleted()
                        } catch {
                            errorRelay.accept("삭제에 실패했습니다.")
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            .map { _ in [] }
            .bind(to: notificationsRelay)
            .disposed(by: disposeBag)
        
        let unreadCount = notificationsRelay
            .map { notifications in
                notifications.filter { !$0.isRead }.count
            }
        
        input.deleteTapped
            .flatMapLatest { [weak self] notification -> Observable<Int> in
                guard let self else { return .empty() }
                
                return Observable.create { observer in
                    Task {
                        do {
                            try await self.notificationUseCase.deleteNotification(id: notification.id)
                            observer.onNext(notification.id)
                            observer.onCompleted()
                        } catch {
                            errorRelay.accept("알림 삭제에 실패했습니다.")
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            .withLatestFrom(notificationsRelay) { deletedId, notifications -> [UserNotification] in
                return notifications.filter { $0.id != deletedId }
            }
            .bind(to: notificationsRelay)
            .disposed(by: disposeBag)
        
        input.approveTapped
            .do(onNext: { [weak self] (notificationId, _, _) in
                self?.approvedNotificationIds.insert(notificationId)
            })
            .flatMapLatest { [weak self] (_, workplaceId, workerId) -> Observable<Void> in
                guard let self else { return .empty() }
                
                return Observable.create { observer in
                    Task {
                        do {
                            try await self.workplaceUseCase.approveJoinRequest(
                                workplaceId: workplaceId,
                                workerId: workerId
                            )
                            observer.onNext(())
                            observer.onCompleted()
                        } catch {
                            errorRelay.accept("승인에 실패했습니다.")
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            .do(onNext: { [weak self] _ in
                guard let self else { return }
                Task {
                    do {
                        let currentNotifications = notificationsRelay.value
                        let fetchedNotifications = try await self.notificationUseCase.fetchNotifications()
                        let mergedNotifications = fetchedNotifications.map { fetched -> UserNotification in
                            if let current = currentNotifications.first(
                                where: { $0.id == fetched.id }
                            ),
                               current.isRead {
                                return UserNotification(
                                    id: fetched.id,
                                    senderId: fetched.senderId,
                                    receiverId: fetched.receiverId,
                                    title: fetched.title,
                                    content: fetched.content,
                                    sentAt: fetched.sentAt,
                                    readAt: current.readAt,
                                    type: fetched.type,
                                    metadata: fetched.metadata
                                )
                            }
                            return fetched
                        }

                        let sortedNotification = mergedNotifications.sorted { $0.sentAt > $1.sentAt }
                        let notificationsWithLocalState = self.applyLocalState(to: sortedNotification)

                        notificationsRelay.accept(notificationsWithLocalState)
                    } catch {
                        // 에러
                    }
                }
            })
            .bind(to: approveSuccessRelay)
            .disposed(by: disposeBag)
        
        input.rejectTapped
            .do(onNext: { [weak self] (notificationId, _, _) in
                self?.rejectedNotificationIds.insert(notificationId)
            })
            .flatMapLatest { [weak self] (_, workplaceId, workerId) -> Observable<Void> in
                guard let self else { return .empty() }
                
                return Observable.create { observer in
                    Task {
                        do {
                            try await self.workplaceUseCase.rejectJoinRequest(
                                workplaceId: workplaceId,
                                workerId: workerId
                            )
                            observer.onNext(())
                            observer.onCompleted()
                        } catch {
                            errorRelay.accept("거절에 실패했습니다.")
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            .do(onNext: { [weak self] _ in
                guard let self else { return }
                Task {
                    do {
                        let currentNotifications = notificationsRelay.value

                        let fetchedNotifications = try await self.notificationUseCase.fetchNotifications()

                        let mergedNotifications = fetchedNotifications.map { fetched -> UserNotification in
                            if let current = currentNotifications.first(
                                where: { $0.id == fetched.id }
                            ),
                               current.isRead {
                                return UserNotification(
                                    id: fetched.id,
                                    senderId: fetched.senderId,
                                    receiverId: fetched.receiverId,
                                    title: fetched.title,
                                    content: fetched.content,
                                    sentAt: fetched.sentAt,
                                    readAt: current.readAt,
                                    type: fetched.type,
                                    metadata: fetched.metadata
                                )
                            }
                            return fetched
                        }

                        let sortedNotification = mergedNotifications.sorted { $0.sentAt > $1.sentAt }
                        let notificationsWithLocalState = self.applyLocalState(to: sortedNotification)

                        notificationsRelay.accept(notificationsWithLocalState)
                    } catch {
                        // 에러
                    }
                }
            })
            .bind(to: rejectSuccessRelay)
            .disposed(by: disposeBag)
        
        return Output(
            notifications: notificationsRelay.asDriver(),
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asSignal(),
            unreadCount: unreadCount.asDriver(onErrorJustReturn: 0),
            approveSuccess: approveSuccessRelay.asSignal(),
            rejectSuccess: rejectSuccessRelay.asSignal()
        )
    }
}
