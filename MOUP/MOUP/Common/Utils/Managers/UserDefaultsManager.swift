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
    
    var hasSignIn: Bool? {
        get { UserDefaults.standard.bool(forKey: "has_sign_in") }
        set {
            if let value = newValue {
                UserDefaults.standard.set(value, forKey: "has_sign_in")
            } else {
                UserDefaults.standard.removeObject(forKey: "has_sign_in")
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
    
    
    func removeHasSignIn() {
        UserDefaults.standard.removeObject(forKey: "has_sign_in")
    }
    
    func removeUserRole() {
        UserDefaults.standard.removeObject(forKey: "user_role")
    }
    
    func removeFCMToken() {
        UserDefaults.standard.removeObject(forKey: "fcm_token")
    }
    
    func clearAllData() {
        removeHasSignIn()
        removeUserRole()
        removeFCMToken()
    }
}
