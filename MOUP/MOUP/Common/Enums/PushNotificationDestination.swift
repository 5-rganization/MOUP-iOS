//
//  PushNotificationDestination.swift
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
