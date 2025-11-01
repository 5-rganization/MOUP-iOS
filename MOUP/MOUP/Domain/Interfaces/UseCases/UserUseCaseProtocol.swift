//
//  UserUseCaseProtocol.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

protocol UserUseCaseProtocol: AnyObject {
    func fetchProfile() async throws -> UserProfile
    func updateNickname(_ nickname: String) async throws -> String
}
