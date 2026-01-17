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
    case decodeError // 디코딩이 원활하지 않았을 때
    case badRequest // 400
    case forbidden // 403
    case notFound // 404
    case invalidField // 422
    case unknown // 기타
}

extension NetworkError {
    // 사용자 친화 에러 메시지
    var errorDescription: String? {
        switch self {
        case .serverError:
            "현재 서버가 불안정합니다. 잠시 후 다시 시도해주세요."
        case .noResponse, .invalidResponse, .decodeError, .badRequest, .forbidden, .notFound, .invalidField, .unknown:
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
        case .decodeError:
            "디코딩 과정 문제 발생"
        case .badRequest:
            "잘못된 요청입니다."
        case .forbidden:
            "권한이 없습니다."
        case .notFound:
            "요청한 정보를 찾을 수 없습니다."
        case .invalidField:
            "유효하지 않은 값입니다."
        case .unknown:
            "알 수 없는 오류가 발생했습니다."
        }
    }
}
