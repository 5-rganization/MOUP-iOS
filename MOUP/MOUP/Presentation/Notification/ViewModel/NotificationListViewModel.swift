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
    }
    
    // MARK: - Output
    
    struct Output {
        let notifications: Driver<[UserNotification]>
        let isLoading: Driver<Bool>
        let error: Signal<String>
        let unreadCount: Driver<Int>
    }
    
    // MARK: - Properties
    
    private let notificationUseCase: NotificationUseCaseProtocol
    private let disposeBag = DisposeBag()
    
    // MARK: - Initializer
    
    init(notificationUseCase: NotificationUseCaseProtocol) {
        self.notificationUseCase = notificationUseCase
    }
    
    // MARK: - Transform
    
    func transform(_ input: Input) -> Output {
        let loadingRelay = BehaviorRelay<Bool>(value: false)
        let notificationsRelay = BehaviorRelay<[UserNotification]>(value: [])
        let errorRelay = PublishRelay<String>()
        
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
                            let notifications = try await self.notificationUseCase.fetchNotifications()
                            
                            let sortedNotification = notifications.sorted { $0.sentAt > $1.sentAt }
                            
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
                            print("읽음 처리 실패: \(error)")
                            observer.onCompleted()
                        }
                    }
                    return Disposables.create()
                }
            }
            .withLatestFrom(notificationsRelay) { tappedNotificationId, notifications -> [UserNotification] in
                return notifications.map { notification in
                    if notification.id == tappedNotificationId && !notification.isRead {
                        return UserNotification(
                            id: notification.id,
                            senderId: notification.senderId,
                            receiverId: notification.receiverId,
                            title: notification.title,
                            content: notification.content,
                            sentAt: notification.sentAt,
                            readAt: Date()
                        )
                    }
                    return notification
                }
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
                        readAt: notification.readAt ?? Date()
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
        
        return Output(
            notifications: notificationsRelay.asDriver(),
            isLoading: loadingRelay.asDriver(),
            error: errorRelay.asSignal(),
            unreadCount: unreadCount.asDriver(onErrorJustReturn: 0)
        )
    }
}
