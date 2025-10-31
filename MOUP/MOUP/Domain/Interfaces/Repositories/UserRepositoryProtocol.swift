//
//  UserRepositoryProtocol.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

protocol UserRepositoryProtocol: AnyObject {
    func fetchProfile() async throws -> UserProfile
}
