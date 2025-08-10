//
//  GoogleAuthUseCaseProtocol.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation

protocol AuthUseCaseProtocol: AnyObject {
    func signInWithGoogle(requestDTO: SignInRequestDTO) async throws
}
