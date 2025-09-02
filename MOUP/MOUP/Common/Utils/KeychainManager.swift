//
//  KeychainManager.swift
//  MOUP
//
//  Created by 송규섭 on 9/3/25.
//

import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()

    private init() {}

    /// 토큰을 키체인에 저장합니다.
    func save(key: String, token: String) {
        guard let data = token.data(using: .utf8) else {
            assertionFailure("Token to Data 변환 실패")
            return
        }
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ]
        SecItemDelete(query)
        let status = SecItemAdd(query, nil)
        assert(status == noErr, "failed to save Token")
    }

    /// 키체인에 저장되어 있는지 확인 후 반환합니다.
    func read(key: String) -> String? {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        assert(status == noErr || status == errSecItemNotFound, "failed to read Token")

        if status == noErr, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    /// 키체인에 저장되어 있는 key에 대응되는 값을 삭제합니다.
    func delete(key: String) {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        let status = SecItemDelete(query)
        assert(status == noErr, "failed to delete the value, status code = \(status)")
    }
}
