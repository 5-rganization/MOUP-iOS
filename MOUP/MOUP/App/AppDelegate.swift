//
//  AppDelegate.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import os
import UIKit
import FirebaseCore
import FirebaseCrashlytics
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AppDelegate")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        let idfv = UIDevice.current.identifierForVendor?.uuidString
        Crashlytics.crashlytics().setUserID(idfv)
        
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if let error {
                self.logger.error("알림 권한 요청 실패: \(error.localizedDescription)")
            }
            self.logger.debug("알림 권한: \(granted)")
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        self.logger.error("APNs 등록 실패: \(error.localizedDescription)")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.logger.debug("FCM token: \(fcmToken ?? "")")
        
        if let token = fcmToken {
            UserDefaultsManager.shared.fcmToken = token
            FCMTokenManager.shared.syncTokenToServer()
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        self.logger.debug("포그라운드 알림: \(userInfo)")
        NotificationCenter.default.post(
            name: .pushNotificationReceived,
            object: nil,
            userInfo: userInfo
        )
        completionHandler([.banner, .sound, .badge])
    }
    
    // 알림 탭
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        self.logger.debug("알림 탭: \(userInfo)")
        
        handleNotificationTap(userInfo)
        
        completionHandler()
    }
    
    private func handleNotificationTap(_ userInfo: [AnyHashable: Any]) {
        let notificationTypeString = userInfo[PushNotificationKey.type] as? String
        let notificationType = PushNotificationType(from: notificationTypeString)
        
        if let notificationType = notificationType {
            self.logger.debug("알림 타입: \(notificationType.rawValue)")
        } else {
            self.logger.warning("알림 타입이 없거나 알 수 없는 타입입니다: \(notificationTypeString ?? "nil")")
        }
        
        let destination = determineDestination(for: notificationType)
        
        // 푸시 알림 페이로드에서 workerId, workplaceId 추출 (String으로 전달됨)
        let workerIdString = userInfo[PushNotificationKey.workerId] as? String
        let workplaceIdString = userInfo[PushNotificationKey.workplaceId] as? String

        let workerId = workerIdString.flatMap { Int($0) }
        let workplaceId = workplaceIdString.flatMap { Int($0) }

        postNotificationTappedEvent(
            destination: destination,
            type: notificationTypeString,
            workerId: workerId,
            workplaceId: workplaceId
        )
    }
    
    private func determineDestination(
        for type: PushNotificationType?
    ) -> PushNotificationDestination {
        guard let type else {
            return .notificationList
        }
        
        switch type {
        case .inviteApproved, .inviteRejected, .inviteRequest, .paydayReminder:
            return .notificationList
        }
    }
    
    private func postNotificationTappedEvent(
        destination: PushNotificationDestination,
        type: String?,
        workerId: Int?,
        workplaceId: Int?
    ) {
        var userInfo: [String: Any] = [
            PushNotificationKey.destination: destination.rawValue
        ]
        
        if let type = type {
            userInfo[PushNotificationKey.type] = type
        }
        
        if let workerId = workerId {
            userInfo[PushNotificationKey.workerId] = workerId
        }

        if let workplaceId = workplaceId {
            userInfo[PushNotificationKey.workplaceId] = workplaceId
        }

        NotificationCenter.default.post(
            name: .pushNotificationTapped,
            object: nil,
            userInfo: userInfo
        )
    }
}
