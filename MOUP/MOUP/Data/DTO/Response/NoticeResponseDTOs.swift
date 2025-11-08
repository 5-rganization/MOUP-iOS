//
//  NoticeResponseDTOs.swift
//  MOUP
//
//  Created by 신영 on 11/1/25.
//

import Foundation

struct NoticeResponseDTO: Decodable {
    let id: Int
    let title: String
    let content: String
    let sentAt: String
}
