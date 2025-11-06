//
//  PushNotification.swift
//  MOUP
//
//  Created by 신영 on 11/6/25.
//

import Foundation

enum PushNotificationDestination: String {
    case notificationList = "notificationList"
    case routineDetail = "routineDetail"
    case workDetail = "workDetail"
    case home = "home"
    
    init?(from string: String) {
        self.init(rawValue: string)
    }
}

enum PushNotificationType: String {
    case inviteApproved = "INVITE_APPROVED"
    case inviteRejected = "INVITE_REJECTED"
    case inviteRequest = "INVITE_REQUEST"
    case paydayReminder = "PAYDAY_REMINDER"
    
    init?(from string: String?) {
        guard let string = string else { return nil }
        self.init(rawValue: string)
    }
}

enum PushNotificationKey {
    static let type = "type"
    static let destination = "destination"
}
