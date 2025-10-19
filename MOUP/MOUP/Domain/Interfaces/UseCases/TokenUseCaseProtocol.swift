//
//  TokenUseCaseProtocol.swift
//  MOUP
//
//  Created by 송규섭 on 10/19/25.
//

import Foundation

protocol TokenUseCaseProtocol: AnyObject {
    func renewAccessToken() async throws
    func deleteTokens()
}
