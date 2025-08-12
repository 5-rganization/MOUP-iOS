//
//  DataError.swift
//  MOUP
//
//  Created by 송규섭 on 7/28/25.
//

import Foundation

enum NetworkError: LocalizedError {
    case serverError // 500
    case noResponse
    case invalidResponse(Error) // 정해진 에러 외 케이스
}

extension NetworkError {
    // 사용자 친화 에러 메시지
    var errorDescription: String? {
        switch self {
        case .serverError:
            "현재 서버가 불안정합니다. 잠시 후 다시 시도해주세요."
        case .noResponse, .invalidResponse:
            "예상치 못한 결과가 발생했습니다. 잠시 후 다시 시도해주세요." // TODO: - 사용자 친화 멘트 생각해봐야 함.
        }
    }

    // 디버깅용 에러 메시지
    var debugDescription: String? {
        switch self {
        case .serverError:
            "500, 서버 에러"
        case .noResponse:
            "데이터를 불러올 수 없음"
        case .invalidResponse(let error):
            "invalidResponse: \(error.localizedDescription)"
        }
    }
}
