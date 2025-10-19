//
//  TokenRepositoryProtocol.swift
//  MOUP
//
//  Created by 송규섭 on 10/17/25.
//

import Foundation

protocol TokenRepositoryProtocol: AnyObject {
    func renewAccessToken() async throws
    func deleteTokens()
    func checkSignedIn() -> Bool
    func fetchAccessToken() -> String?
    func fetchRefreshToken() -> String?
}
