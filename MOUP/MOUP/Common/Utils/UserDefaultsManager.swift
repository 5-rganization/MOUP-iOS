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

    var userId: String? { // 로그인 후 받은 userId
        get { UserDefaults.standard.string(forKey: "user_id") }
        set { UserDefaults.standard.set(newValue, forKey: "user_id") }
    }
}
