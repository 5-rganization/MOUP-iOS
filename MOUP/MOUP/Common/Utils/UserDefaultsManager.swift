//
//  UserDefaultsManager.swift
//  MOUP
//
//  Created by 송규섭 on 8/6/25.
//

import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init() {}
    
    var hasLaunchedBefore: Bool? {
        get { UserDefaults.standard.bool(forKey: "has_launched_before") }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: "has_launched_before")
            } else {
                UserDefaults.standard.removeObject(forKey: "has_launched_before")
            }
        }
    }

    var userRole: String? {
        get { UserDefaults.standard.object(forKey: "user_role") as? String }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: "user_role")
            } else {
                UserDefaults.standard.removeObject(forKey: "user_role")
            }
        }
    }
    
    var fcmToken: String? {
        get { UserDefaults.standard.string(forKey: "fcm_token") }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: "fcm_token")
            } else {
                UserDefaults.standard.removeObject(forKey: "fcm_token")
            }
        }
    }
    
    func removeUserRole() {
        UserDefaults.standard.removeObject(forKey: "user_role")
    }
    
    func removeFCMToken() {
        UserDefaults.standard.removeObject(forKey: "fcm_token")
    }
    
    func clearAllData() {
        removeUserRole()
        removeFCMToken()
    }
}
