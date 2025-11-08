//
//  NoticeUseCase.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

final class NoticeUseCase: NoticeUseCaseProtocol {
    private let noticeRepository: NoticeRepositoryProtocol
    
    init(noticeRepository: NoticeRepositoryProtocol) {
        self.noticeRepository = noticeRepository
    }
    
    func fetchNotices() async throws -> [Notice] {
        try await noticeRepository.fetchNotices()
    }
}
