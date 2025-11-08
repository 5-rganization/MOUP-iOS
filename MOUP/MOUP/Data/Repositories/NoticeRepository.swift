//
//  NoticeRepository.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

final class NoticeRepository: NoticeRepositoryProtocol {
    private let noticeService: NoticeServiceProtocol
    
    init(noticeService: NoticeServiceProtocol) {
        self.noticeService = noticeService
    }
    
    func fetchNotices() async throws -> [Notice] {
        let dtos = try await noticeService.fetchNotices()
        return dtos.map { mapToEntity($0) }
    }
    
    private func mapToEntity(_ dto: NoticeResponseDTO) -> Notice {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let sentDate = dateFormatter.date(from: dto.sentAt) ?? Date()
        
        return Notice(
            id: dto.id,
            title: dto.title,
            content: dto.content,
            sentAt: sentDate
        )
    }
}
