//
//  AuthResponseEnum.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation

enum loginResponseEnum {
    case success // 성공, 200
    case notMember // 회원이 아닐 시, 404
    case failure(Error)
}
