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
    private let useDummyData = true
    
    func fetchNotices() async throws -> [NoticeResponseDTO] {
        if useDummyData {
            return try await fetchDummyNotices()
        } else {
            return try await fetchRealNotices()
        }
    }
    
    // ✅ 더미 데이터 로드
    private func fetchDummyNotices() async throws -> [NoticeResponseDTO] {
        print("========== 공지사항 조회 (더미 데이터) ==========")
        
        // 네트워크 딜레이 시뮬레이션
        try await Task.sleep(nanoseconds: 500_000_000)  // 0.5초
        
        guard let url = Bundle.main.url(forResource: "DummyNotice", withExtension: "json") else {
            print("❌ DummyNotice.json 파일을 찾을 수 없습니다")
            throw NetworkError.noResponse
        }
        
        let data = try Data(contentsOf: url)
        let dtos = try JSONDecoder().decode([NoticeResponseDTO].self, from: data)
        
        print("✅ 공지사항 \(dtos.count)개 조회 성공 (더미)")
        print("==========================================")
        
        return dtos
    }
    
    func fetchRealNotices() async throws -> [NoticeResponseDTO] {
        let request = session.request(NoticeRouter.fetchNotices)
        let response = await request.serializingDecodable([NoticeResponseDTO].self).response
        
        print("========== 공지사항 조회 ==========")
        print("statusCode: \(response.response?.statusCode ?? -1)")
        
        if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
            print("응답: \(jsonString)")
        }
        
        if let dtos = response.value {
            print("✅ 공지사항 \(dtos.count)개 조회 성공")
        }
        print("==================================")
        
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
