//
//  AuthResponseDTOs.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation

/// 인증 관련(로그인, 회원가입 등) API 호출 결과 관련 모델들을 관리합니다.
struct SignInResponseDTO: Decodable {
    let userId: String? // 그 밖의 errorMessage 등 데이터들은 statusCode 기반을 넘어 추가 정보를 필요로 할 경우 추가
    let role: String?
}
// TODO: - Service 구조 변경 (미리 statusCode 확인 후 파싱), DTO 내부 옵셔널 x
