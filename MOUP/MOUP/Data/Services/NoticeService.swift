//
//  NoticeService.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation
import Alamofire

protocol NoticeServiceProtocol: AnyObject {
    func fetchNotices() async throws -> [NoticeResponseDTO]
}

final class NoticeService: NoticeServiceProtocol {
    private lazy var session = NetworkManager.shared.session
    
    func fetchNotices() async throws -> [NoticeResponseDTO] {
        let request = session.request(NoticeRouter.fetchNotices)
        let response = await request.serializingDecodable([NoticeResponseDTO].self).response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.noResponse
        }
        
        switch statusCode {
        case 200:
            guard let dtos = response.value else {
                throw NetworkError.noResponse
            }
            return dtos
        case 401:
            print("공지사항 조회 실패: 인증 실패")
            throw NetworkError.serverError
        case 404:
            print("공지사항 조회 실패: 조회 결과 없음")
            return []  // 빈 배열 반환
        default:
            print(NetworkError.serverError.debugDescription!)
            throw NetworkError.serverError
        }
    }
}
