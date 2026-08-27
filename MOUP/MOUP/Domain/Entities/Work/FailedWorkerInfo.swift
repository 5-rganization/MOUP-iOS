//
//  FailedWorkerInfo.swift
//  MOUP
//
//  Created by 서동환 on 10/31/25.
//

/// 근무 생성에 실패한 근무자 정보 Entity
struct FailedWorkerInfo {
    /// 재시도 대상을 추리는 데 쓴다. 닉네임은 중복될 수 있어 식별자로 삼지 않는다.
    let workerId: Int
    let nickname: String
    let reason: String
}
